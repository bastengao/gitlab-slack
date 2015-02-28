class Webhook < ActiveRecord::Base
  belongs_to :user

  validates :name, :slack_incoming_hook, presence: true
  validates :slack_incoming_hook, format: { with: /https:\/\/hooks.slack.com\/services\/+/}

  def hook_id
    ScatterSwap.hash(id)
  end
end
