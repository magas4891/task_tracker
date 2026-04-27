# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    oauth_callback('Google')
  end

  def twitter2
    oauth_callback('X')
  end

  def failure
    if request.env["omniauth.error"]&.respond_to?(:response) && request.env["omniauth.error"].response&.respond_to?(:status) && request.env["omniauth.error"].response.status == 503
      redirect_to new_user_session_path, alert: "X's servers are temporarily unavailable (503). Please try again in a moment or check https://docs.x.com/status"
    else
      super
    end
  end

  private

  def oauth_callback(kind)
    @user = User.find_or_create_from_omniauth(request.env['omniauth.auth'])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
    else
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join(', ')
    end
  end
end
