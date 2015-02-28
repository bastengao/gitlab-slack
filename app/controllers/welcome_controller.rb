class WelcomeController < ApplicationController
  def index
    redirect_to webhooks_url if user_signed_in?
  end
end
