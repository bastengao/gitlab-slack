class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :registerable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:gitlab]

  has_many :webhooks, dependent: :destroy

  def self.from_omniauth(auth)
    access_token = auth.credentials.token
    private_token = auth.extra.raw_info.private_token

    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.access_token = access_token
      user.private_token = private_token
      logger.info auth.info.name # assuming the user model has a name
      logger.info auth.info.image # assuming the user model has an image
    end
  end
end
