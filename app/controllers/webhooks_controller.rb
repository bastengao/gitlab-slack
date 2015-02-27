class WebhooksController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:hook]

  before_action :authenticate_user!, except: :hook
  before_action :set_webhook, only: [:edit, :update, :destroy]

  def index
    @webhooks = current_user.webhooks
  end

  def new
    @webhook = Webhook.new
  end

  def create
    @webhook = Webhook.new(webhook_params)
    @webhook.user_id = current_user.id
    if @webhook.save
      redirect_to webhooks_url, notice: 'Save successfully'
    else
      flash.now.alert = 'Save failed'
      render :new
    end
  end

  def edit
  end

  def update
    if @webhook.update_attributes(webhook_params)
      redirect_to webhooks_url, notice: 'Save successfully'
    else
      flash.now.alert = 'Save failed'
      render :edit
    end
  end

  def destroy
    if @webhook.destroy
      redirect_to webhooks_url, notice: 'Destroy successfully'
    else
      redirect_to webhooks_url, alert: 'Destroy failed'
    end
  end

  def hook
    @webhook = Webhook.find params[:id]
    post_data = request.raw_post
    # logger.info post_data

    hook_msg = GitlabHookMessage.new JSON.parse(post_data)

    notifier = Slack::Notifier.new @webhook.slack_incoming_hook
    notifier.ping 'push ' + hook_msg.type #, icon_url: hook_msg['user']['avatar_url']
    notifier.ping post_data.force_encoding('utf-8')

    render nothing: true
  end

  private
  def set_webhook
    @webhook = Webhook.find params[:id]
  end

  def webhook_params
    params.require(:webhook).permit(:name, :slack_incoming_hook, :user_id)
  end
end
