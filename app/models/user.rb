class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :twitter2]

  has_one :dashboard

  has_many :tasks

  after_create -> { create_dashboard }

  def self.from_omniauth(auth)
    pp ' *** '*100, auth
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email.presence || "#{auth.uid}@#{auth.provider}.oauth"
      user.password = Devise.friendly_token[0, 20]
      first_name, last_name = parse_omniauth_name(auth)
      user.first_name = first_name
      user.last_name = last_name
    end
  end

  def self.parse_omniauth_name(auth)
    name = auth.info&.name.to_s.strip
    if name.present?
      parts = name.split(/\s+/, 2)
      [parts[0], parts[1].presence || '-']
    else
      [auth.info&.nickname.presence || 'User', '-']
    end
  end

  def password_required?
    super && provider.blank?
  end
end
