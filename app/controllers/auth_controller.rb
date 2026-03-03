class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]
  after_action       :clear_session_data, only: [:callback]

  CLIENT_ID     = ENV.fetch('X_CLIENT_ID')
  CLIENT_SECRET = ENV.fetch('X_CLIENT_SECRET')
  REDIRECT_URI  = 'http://localhost:3000/auth/x/callback'
  AUTH_URL      = 'https://x.com/i/oauth2/authorize'
  TOKEN_URL     = 'https://api.x.com/2/oauth2/token'

  CODE_VERIFIER  = SecureRandom.urlsafe_base64(32)
  CODE_CHALLENGE = Base64.urlsafe_encode64(Digest::SHA256.digest(CODE_VERIFIER), padding: false)

  def login
    code_verifier  = SecureRandom.urlsafe_base64(32)
    state          = SecureRandom.hex(16)
    code_challenge = Base64.urlsafe_encode64(
      Digest::SHA256.digest(code_verifier),
      padding: false
    )

    session[:code_verifier] = code_verifier
    session[:oauth_state]   = state

    auth_params = {
      response_type:         'code',
      client_id:             CLIENT_ID,
      redirect_uri:          REDIRECT_URI,
      scope:                 'tweet.read users.read offline.access users.email',
      state:                 state,
      code_challenge:        code_challenge,
      code_challenge_method: 'S256'
    }

    authorize_url = "#{AUTH_URL}?#{URI.encode_www_form(auth_params)}"

    redirect_to authorize_url, allow_other_host: true
  end

  def callback
    if params[:state] != session[:oauth_state]
      return render plain: "State mismatch - possible CSRF", status: :bad_request
    end

    if params[:error].present?
      return render plain: "Error from X: #{params[:error_description]}", status: :unauthorized
    end

    code = params[:code]
    return render plain: "No code received", status: :bad_request unless code

    client = OAuth2::Client.new(
      CLIENT_ID,
      CLIENT_SECRET,
      site:          'https://api.x.com',
      token_url:     '/2/oauth2/token',
      authorize_url: '/i/oauth2/authorize'
    )

    begin
      token = client.auth_code.get_token(
        code,
        redirect_uri: REDIRECT_URI,
        code_verifier: session[:code_verifier],
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
      )
      user_info = fetch_user_info(token.token)
      user      = User.from_omniauth('x', user_info)

      sign_in user

      redirect_to root_path, notice: "Signed in with X!"
    rescue OAuth2::Error => e
      Rails.logger.error "X OAuth error: #{e.response.body}"
      redirect_to root_path, alert: "Authentication failed: #{e.description || 'Service issue'}"
    end
  end

  private

  def fetch_user_info(access_token)
    response = HTTParty.get(
      'https://api.x.com/2/users/me?user.fields=name,username,confirmed_email,profile_image_url',
      headers: { 'Authorization' => "Bearer #{access_token}" }
    )

    raise OAuth2::Error, "Failed to fetch user info: #{response.body}" unless response.code == 200

    JSON.parse(response.body)
  end

  def clear_session_data
    session.delete(:code_verifier)
    session.delete(:oauth_state)
  end
end
