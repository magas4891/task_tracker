module UserHelper
  def omniauth_id(auth)
    auth.fetch('sub', nil) || auth.dig('data', 'id')
  end

  def omniauth_email(auth)
    auth.fetch('email', nil) || auth.dig('data', 'confirmed_email')
  end

  def omniauth_first_name(auth)
    auth.fetch('given_name', nil) || auth.dig('data', 'username')
  end

  def omniauth_last_name(auth)
    auth.fetch('family_name', nil) || auth.dig('data', 'username')
  end
end
