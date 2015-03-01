class WebhooksController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:hook]

  before_action :authenticate_user!, except: :hook
  before_action :set_webhook, only: [:show, :edit, :update, :destroy, :test]

  def index
    @webhooks = current_user.webhooks
  end

  def show
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
    id = ScatterSwap.reverse_hash(params[:id])

    logger.info request.raw_post

    @webhook = Webhook.find id
    post_data = JSON.parse(request.raw_post).deep_symbolize_keys

    hook_msg = GitlabHookMessage.new post_data.merge({ project_name: 'test', project_url: 'test_url'})

    notifier = Slack::Notifier.new @webhook.slack_incoming_hook
    notifier.ping hook_msg.pretext, attachments: hook_msg.attachments

    render nothing: true
  end

  def test
    @webhook = Webhook.find params[:id]
    notifier = Slack::Notifier.new @webhook.slack_incoming_hook
    notifier.ping 'Hello Slack!', icon_emoji: ":trollface:"
  end

  private
  def set_webhook
    @webhook = Webhook.find params[:id]
  end

  def webhook_params
    params.require(:webhook).permit(:name, :slack_incoming_hook, :user_id)
  end
end
