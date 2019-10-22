class IndexSlacker < ApplicationSlacker
  class << self
    def build_index_slack_value(index_price_value)
      value = IndexSlackValue.new(index_price_value.code)
      value.index_price_value = index_price_value
      value
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
    <<-EOS
【#{value.index_name}】
#{index_price_page_url_of(value.index_code)}
    EOS
  end

  def index_price_page_url_of(index_code)
    "https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETmgR001Control&_PageID=WPLETmgR001Mdtl20&_DataStoreID=DSWPLETmgR001Control&_ActionID=DefaultAID&burl=iris_indexDetail&cat1=market&cat2=index&file=index.html&getFlg=on&dir=tl1-idxdtl%7Ctl2-.#{::WebAccessor::Sbi::IndexParams::INDEX_URL_CODE_HASH[index_code]}%7Ctl5-jpn"
  end
end