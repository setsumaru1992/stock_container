class StockSlacker < ApplicationSlacker

  def notice_bought_stocks(bought_stock_values)
    notice("---- 保有株 ----")
    bought_stock_values.each do |value|
      begin
        price = value.stock_price_value.price
        ref_price = value.stock_price_value.reference_price
        message = <<-EOS
【#{value.stock.code} #{value.stock.name}】
(取得)#{ref_price} (現在)#{price}
(利益)#{price - ref_price}(#{profit_rate(ref_price, price)}%)
5%↑   #{by_percent_of(0.05, price)}
10%↑  #{by_percent_of(0.1, price)}
20%↑  #{by_percent_of(0.2, price)}
5%↓   #{by_percent_of(-0.05, price)}
10%↓  #{by_percent_of(-0.1, price)}
20%↓  #{by_percent_of(-0.2, price)}
https://moyamoya.space/dailyutil/stockInfo/access2sbi_chart?stock_code=#{value.stock.code}

特徴：#{value.stock_condition.feature}
#{value.stock_financial_condition.try(:is_nikkei_average_group) ? "日経225" : nil}
決算：#{value.stock.settlement_month}月
        EOS
        notice(message)
      rescue => e
        ErrorSlacker.new.notice_error(e)
        notice("エラー発生")
        Rails.logger.warn(e)
      end
    end
  end

  def notice_bought_and_favorite_stocks_with_chart(bought_stocks: nil, favorite_stocks: nil)
    notice("TODO Railsアプリでnotice_bought_and_favorite_stocks_with_chart実装")
  end

  private

  def webhook_url
    ENV["STOCK_SLACK_WEBHOOK_URL"]
  end

  def profit_rate(before, after)
    return "--" unless before.kind_of?(Integer) && after.kind_of?(Integer)
    ((after - before).fdiv(before) * 100).round(1)
  end

  def by_percent_of(percent, target)
    return "--" unless percent.kind_of?(Float) && target.kind_of?(Integer)
    target - (target * percent).round
  end
end