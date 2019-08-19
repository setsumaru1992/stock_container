class ApplicationSlacker

  def initialize
    @slack = Slack::Notifier.new(webhook_url)
  end

  def notice(text)
    @slack.ping(text)
  end

  def notice_with_image(text, image_url)
    attachment_image = {image_url: image_url}
    @slack.ping(text, attachments: [attachment_image])
  end

  private

  def webhook_url
    raise "Please define webhook url in concrete method."
  end

end