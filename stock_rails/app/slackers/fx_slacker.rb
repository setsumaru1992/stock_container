class FxSlacker < PriceNoticeSlacker
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
    v = value.fx_price_value
    # チャート画像はslackでサムネイル画像が生成され、古い画像がキャッシュされ続けるのでS3の固定URLのものは載せない
    <<-EOS
【円→USD】
#{current_price_message(v.price, previous_price: v.reference_price)}
SBIページ
#{fx_price_page_url}
チャート画像
#{::ImageManager::FxChart::YenToUsdInShortTerm::IMAGE_URL}
    EOS
  end

  def increased_and_decreaced_price_message(cur_price, leverage: nil)
    message = ""
    leverage_rate_for_calc = 1
    if leverage.present?
      message << "(レバレッジ#{leverage}倍時の増減)\n"
      leverage_rate_for_calc = 1.fdiv(leverage)
    end
    message << <<-EOS
5%↑    #{by_percent_of(0.05 * leverage_rate_for_calc, cur_price, digit: 2).to_s(:delimited)}  5%↓    #{by_percent_of(-0.05 * leverage_rate_for_calc, cur_price, digit: 2).to_s(:delimited)}
10%↑  #{by_percent_of(0.1 * leverage_rate_for_calc, cur_price, digit: 2).to_s(:delimited)}  10%↓  #{by_percent_of(-0.1 * leverage_rate_for_calc, cur_price, digit: 2).to_s(:delimited)}
20%↑  #{by_percent_of(0.2 * leverage_rate_for_calc, cur_price, digit: 2).to_s(:delimited)}  20%↓  #{by_percent_of(-0.2 * leverage_rate_for_calc, cur_price, digit: 2).to_s(:delimited)}
    EOS
    message
  end

  def fx_price_page_url
    "https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETmgR001Control&_PageID=WPLETmgR001Mdtl20&_DataStoreID=DSWPLETmgR001Control&_ActionID=DefaultAID&burl=iris_indexDetail&cat1=market&cat2=index&dir=tl1-idxdtl%7Ctl2-JPY%3DX%7Ctl5-jpn&file=index.html&getFlg=on&OutSide=on"
  end
end
