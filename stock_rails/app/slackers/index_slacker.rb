class IndexSlacker < PriceNoticeSlacker
  NO_VALUE = "--".freeze

  class << self
    def build_index_slack_values(index_price_values)
      index_price_values.map do |index_price|
        build_index_slack_value(index_price)
      end.compact
    end

    def build_index_slack_value(index_price_value)
      value = IndexSlackValue.new(index_price_value.code)
      value.index_price_value = index_price_value
      value
    rescue => e
      code = index_price_value.code
      ErrorSlacker.new.notice_error(e)
      notice("(エラー発生)インデックス:#{code}の情報取得失敗")
      Rails.logger.warn(e)
      nil
    end
  end

  def notice_index_with_chart(index_values)
    index_values.each do |value|
      begin
        notice_with_image(index_message(value), parse_image_path_to_image_url(value.index_price_value.chart_path))
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

  def index_message(value)
    v = value.index_price_value
    <<-EOS
【#{value.index_name}】
#{current_price_message(v.price, previous_price: v.reference_price)}
#{increased_and_decreaced_price_message(v.price)}
TODO: 表示はしているがDBに値登録していないため修正
#{index_price_page_url_of(value.index_code)}
    EOS
  end

  def index_price_page_url_of(index_code)
    "https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETmgR001Control&_PageID=WPLETmgR001Mdtl20&_DataStoreID=DSWPLETmgR001Control&_ActionID=DefaultAID&burl=iris_indexDetail&cat1=market&cat2=index&file=index.html&getFlg=on&dir=tl1-idxdtl%7Ctl2-.#{::WebAccessor::Sbi::IndexParams::INDEX_URL_CODE_HASH[index_code]}%7Ctl5-jpn"
  end
end
