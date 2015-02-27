class WebhookController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def update
    post_data = request.raw_post
    # logger.info post_data

    hook_msg = GitlabHookMessage.new JSON.parse(post_data)

    data = JSON.parse(post_data)

    notifier = Slack::Notifier.new ENV['WEBHOOK']
    notifier.ping 'push ' + hook_msg.type #, icon_url: hook_msg['user']['avatar_url']
    notifier.ping post_data.force_encoding('utf-8')

    render nothing: true
  end
end
