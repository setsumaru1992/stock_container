class ErrorSlacker < ApplicationSlacker

  private

  def webhook_url
    ENV["ERROR_SLACK_WEBHOOK_URL"]
  end
end