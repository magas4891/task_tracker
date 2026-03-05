class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]
  after_action       :clear_session_data, only: [:callback]

  AUTH_URL      = 'https://x.com/i/oauth2/authorize'
  TOKEN_URL     = 'https://api.x.com/2/oauth2/token'

  CODE_VERIFIER  = SecureRandom.urlsafe_base64(32)
  CODE_CHALLENGE = Base64.urlsafe_encode64(Digest::SHA256.digest(CODE_VERIFIER), padding: false)

  OAUTH_PROVIDERS = {
    x: {
      client_id_env:     ENV.fetch('X_CLIENT_ID'),
      client_secret_env: ENV.fetch('X_CLIENT_SECRET'),
      redirect_uri:      'http://localhost:3000/auth/x/callback',
      authorize_url:     'https://x.com/i/oauth2/authorize',
      token_url:         'https://api.x.com/2/oauth2/token',
      user_info_url:     'https://api.x.com/2/users/me?user.fields=name,username,confirmed_email,profile_image_url',
      scope:             'tweet.read users.read offline.access users.email',
      pkce:              true
    },
    google: {
      client_id_env:     ENV.fetch('GOOGLE_CLIENT_ID'),
      client_secret_env: ENV.fetch('GOOGLE_CLIENT_SECRET'),
      redirect_uri:      'http://localhost:3000/auth/google/callback',
      authorize_url:     'https://accounts.google.com/o/oauth2/v2/auth',
      token_url:         'https://oauth2.googleapis.com/token',
      user_info_url:     'https://openidconnect.googleapis.com/v1/userinfo',
      scope:             'openid email profile',
      pkce:              true
    }
  }
  def login
    code_verifier  = SecureRandom.urlsafe_base64(32)
    state          = SecureRandom.hex(16)
    code_challenge = Base64.urlsafe_encode64(
      Digest::SHA256.digest(code_verifier),
      padding: false
    )

    session[:code_verifier] = code_verifier
    session[:oauth_state]   = state
    session[:oauth_provider] = params['provider'] if params['provider'].present?

    auth_params = {
      response_type:         'code',
      client_id:             oauth_provider[:client_id_env].to_s,
      redirect_uri:          oauth_provider[:redirect_uri].to_s,
      scope:                 oauth_provider[:scope].to_s,
      state:                 state,
      code_challenge:        code_challenge,
      code_challenge_method: 'S256'
    }

    authorize_url = "#{oauth_provider[:authorize_url].to_s}?#{URI.encode_www_form(auth_params)}"

    redirect_to authorize_url, allow_other_host: true
  end

  def callback
    if provider.nil? || oauth_provider.nil?
      return render plain: "Unknown or missing provider", status: :bad_request
    end

    if params[:state] != session[:oauth_state]
      return render plain: "State mismatch - possible CSRF", status: :bad_request
    end

    if params[:error].present?
      return render plain: "Error from #{provider}: #{params[:error_description]}", status: :unauthorized
    end

    code = params[:code].to_s
    return render plain: "No code received", status: :bad_request if code.blank?

    begin
      token_uri = URI.parse(oauth_provider[:token_url].to_s)
      site = "#{token_uri.scheme}://#{token_uri.host}"
    rescue => _e
      site = nil
    end

    client = OAuth2::Client.new(
      oauth_provider[:client_id_env].to_s,
      oauth_provider[:client_secret_env].to_s,
      site:          site,
      token_url:     oauth_provider[:token_url].to_s,
      authorize_url: oauth_provider[:authorize_url].to_s
    )

    begin
      token = client.auth_code.get_token(
        code,
        redirect_uri: oauth_provider[:redirect_uri].to_s,
        code_verifier: session[:code_verifier],
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
      )

      user_info = fetch_user_info(token.token, oauth_provider[:user_info_url].to_s)
      user      = User.from_omniauth(provider.to_s, user_info)

      sign_in user

      redirect_to root_path, notice: "Signed in with #{provider}!"
    rescue OAuth2::Error => e
      Rails.logger.error "OAuth error for #{provider}: #{e.response.body}"
      redirect_to root_path, alert: "Authentication failed: #{e.description || 'Service issue'}"
    end
  end

  private

  def fetch_user_info(access_token, user_info_url)
    response = HTTParty.get(
      user_info_url,
      headers: { 'Authorization' => "Bearer #{access_token}" }
    )

    raise OAuth2::Error, "Failed to fetch user info: #{response.body}" unless response.code == 200

    JSON.parse(response.body)
  end

  def clear_session_data
    session.delete(:code_verifier)
    session.delete(:oauth_state)
    session.delete(:oauth_provider)
  end

  def provider
    raw = params['provider'].presence || session[:oauth_provider]
    return nil unless raw
    @_provider ||= raw.to_s.to_sym
  end

  def oauth_provider
    return nil unless provider
    @_oauth_provider ||= OAUTH_PROVIDERS[provider]
  end
end
