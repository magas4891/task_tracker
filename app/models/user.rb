class User < ApplicationRecord
  include UserHelper

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :dashboard

  has_many :tasks

  after_create -> { create_dashboard }

  def self.from_omniauth(provider, auth)
    User.where(provider: provider, uid: omniauth_id(auth)).first_or_create do |user|
      user.email      = omniauth_email(auth) || "#{omniauth_id(auth)}@#{provider}.local"
      user.first_name = omniauth_first_name(auth)
      user.last_name  = omniauth_last_name(auth)
      user.password   = Devise.friendly_token[0, 20]
    end
  end
end
