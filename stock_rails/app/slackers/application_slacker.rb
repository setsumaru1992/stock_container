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

  def parse_image_path_to_image_url(image_path)
    path = image_path.gsub("/var/opt/stock_container/", "")
    "http://153.126.209.119/stockapp/#{path}"
  end

end