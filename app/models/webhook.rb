class Webhook < ActiveRecord::Base
  belongs_to :user

  validates :name, :slack_incoming_hook, presence: true

  # TODO format
end
