class StockSlacker < ApplicationSlacker
  NO_VALUE = "--".freeze

  class << self
    def build_stock_slack_value(stock_price_value)
      code = stock_price_value.code
      # ActiveRecordの直呼びはCQRSの観点から許容
      value = StockSlackValue.new
      value.stock_price_value = stock_price_value
      value.stock = ::Stock.find_by(code: code)
      value.stock_condition = value.stock.stock_conditions.first
      value.stock_financial_condition = value.stock.stock_financial_conditions.first
      value
    end
  end

  def notice_bought_stocks(bought_stock_values)
    notice("---- 保有株 ----")
    bought_stock_values.each do |value|
      begin
        notice(bought_stock_message(value))
      rescue => e
        ErrorSlacker.new.notice_error(e)
        notice("エラー発生")
        Rails.logger.warn(e)
      end
    end
  end

  def notice_bought_and_favorite_stocks_with_chart(favorite_stock_values, bought_stock_values)
    notice("---- 保有株 ----")
    bought_stock_values.each do |value|
      begin
        notice_with_image(bought_stock_message(value), parse_image_path_to_image_url(value.stock_price_value.chart_path))
      rescue => e
        ErrorSlacker.new.notice_error(e)
        notice("エラー発生")
        Rails.logger.warn(e)
      end
    end

    notice("---- ポートフォリオ ----")
    favorite_stock_values
      .sort_by {|favorite_stock_value| favorite_stock_value.stock_price_value.price}.reverse
      .each do |value|
      begin
        notice_with_image(favorite_stock_message(value), parse_image_path_to_image_url(value.stock_price_value.chart_path))
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

  def bought_stock_message(stock_value)
    price = stock_value.stock_price_value.price
    ref_price = stock_value.stock_price_value.reference_price
    <<-EOS
【#{stock_value.stock.code} #{stock_value.stock.name}】#{stock_is_nikkei_average_group(stock_value)}
(現在)#{price} (取得)#{ref_price}
(利益)#{profit(ref_price, price)}(#{profit_rate(ref_price, price)}%)
5%↑    #{by_percent_of(0.05, price)}  5%↓    #{by_percent_of(-0.05, price)}
10%↑  #{by_percent_of(0.1, price)}  10%↓  #{by_percent_of(-0.1, price)}
20%↑  #{by_percent_of(0.2, price)}  20%↓  #{by_percent_of(-0.2, price)}
https://moyamoya.space/dailyutil/stockInfo/access2sbi_chart?stock_code=#{stock_value.stock.code}
#{stock_detail_message(stock_value)}
    EOS
  end

  def favorite_stock_message(stock_value)
    price = stock_value.stock_price_value.price
    ref_price = stock_value.stock_price_value.reference_price
    <<-EOS
【#{stock_value.stock.code} #{stock_value.stock.name}】#{stock_is_nikkei_average_group(stock_value)}
(現在)#{price} (参考価格)#{ref_price}
(差分)#{profit(ref_price, price)}(#{profit_rate(ref_price, price)}%)
5%↑    #{by_percent_of(0.05, price)}
10%↑  #{by_percent_of(0.1, price)}
20%↑  #{by_percent_of(0.2, price)}
https://moyamoya.space/dailyutil/stockInfo/access2sbi_chart?stock_code=#{stock_value.stock.code}
#{stock_detail_message(stock_value)}
    EOS
  end

  def profit(before, after)
    return NO_VALUE unless before.is_a?(Numeric) && after.is_a?(Numeric)
    ((after - before).fdiv(before) * 100).round(1)
  end

  def profit_rate(before, after)
    return NO_VALUE unless before.is_a?(Numeric) && after.is_a?(Numeric)
    ((after - before).fdiv(before) * 100).round(1)
  end

  def by_percent_of(percent, target)
    return NO_VALUE unless percent.is_a?(Numeric) && target.is_a?(Numeric)
    target + (target * percent).round
  end

  def stock_detail_message(stock_value)
    stock_feature(stock_value) + stock_settlement_months(stock_value) + "\n"
  end

  def stock_feature(stock_value)
    feature = stock_value.try(:stock_condition).try(:feature)
    return "" if feature.nil?
    "特徴：#{feature}\n"
  end

  def stock_is_nikkei_average_group(stock_value)
    is_nikkei_average_group = stock_value.try(:stock_financial_condition).try(:is_nikkei_average_group)
    return "" if is_nikkei_average_group.nil?
    "日経225銘柄"
  end

  def stock_settlement_months(stock_value)
    settlement_month = stock_value.try(:stock).try(:settlement_month)
    return "" if settlement_month.nil?
    first_settlement_month = if settlement_month % 3 != 0
      settlement_month
    else
      3
    end
    settlement_months = [
      first_settlement_month,
      first_settlement_month + 3,
      first_settlement_month + 6,
      first_settlement_month + 9
    ]
    "決算：#{settlement_month}月(#{settlement_months.join(", ")}月)\n"
  end

  def parse_image_path_to_image_url(image_path)
    path = image_path.gsub("/var/opt/stock_container/", "")
    "https://kibotsu.com/stockapp/#{path}"
  end
end
