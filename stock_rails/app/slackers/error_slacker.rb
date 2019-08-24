class ErrorSlacker < ApplicationSlacker

  def notice_error(e)
    notice("#{Time.now}\n#{e.backtrace.take(1)}\n\n#{e.to_s}\n\n#{e.backtrace.take(5).join("\n")}")
  end
  private

  def webhook_url
    ENV["ERROR_SLACK_WEBHOOK_URL"]
  end
end