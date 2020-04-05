class FxSlacker < ApplicationSlacker
  NO_VALUE = "--".freeze

  class << self
    def build_fx_slack_values(fx_price_values)
      fx_price_values.map do |fx_price|
        build_fx_slack_value(fx_price)
      end.compact
    end

    def build_fx_slack_value(fx_price_value)
      value = FxSlackValue.new
      value.fx_price_value = fx_price_value
      value
    rescue => e
      ErrorSlacker.new.notice_error(e)
      notice("(エラー発生)円->USDの情報取得失敗")
      Rails.logger.warn(e)
      nil
    end
  end

  def notice_fx_with_chart(fx_values)
    fx_values.each do |value|
      begin
        notice_with_image(fx_message(value), parse_image_path_to_image_url(value.fx_price_value.chart_path))
      rescue => e
        ErrorSlacker.new.notice_error(e)
        notice("エラー発生")
        Rails.logger.warn(e)
      end
    end
  end

  private

  def webhook_url
    ENV["STOCK_SLACK_WEBHOOK_URL"]
  end

  def fx_message(value)
    price = value.fx_price_value.price
    ref_price = value.fx_price_value.reference_price
    <<-EOS
【円→USD】
(現在)#{price} (前日)#{ref_price}
(差分)#{profit(ref_price, price)}(#{profit_rate(ref_price, price)}%)
TODO: 表示はしているがDBに値登録していないため修正
#{fx_price_page_url}
    EOS
  end

  def profit(before, after)
    return NO_VALUE unless before.is_a?(Numeric) && after.is_a?(Numeric)
    after - before
  end

  def profit_rate(before, after)
    return NO_VALUE unless before.is_a?(Numeric) && after.is_a?(Numeric)
    ((after - before).fdiv(before) * 100).round(1)
  end

  def fx_price_page_url
    "https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETmgR001Control&_PageID=WPLETmgR001Mdtl20&_DataStoreID=DSWPLETmgR001Control&_ActionID=DefaultAID&burl=iris_indexDetail&cat1=market&cat2=index&dir=tl1-idxdtl%7Ctl2-JPY%3DX%7Ctl5-jpn&file=index.html&getFlg=on&OutSide=on"
  end
end
