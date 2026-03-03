class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :dashboard

  has_many :tasks

  after_create -> { create_dashboard }

  def self.from_omniauth(provider, auth)
    User.where(provider: provider, uid: auth['data']['id']).first_or_create do |user|
      user.email      = auth['data']['confirmed_email'] || "#{auth['data']['id']}@#{provider}.local"
      user.first_name = auth['data']['name']
      user.last_name  = auth['data']['username']
      user.password   = Devise.friendly_token[0, 20]
    end
  end
end
