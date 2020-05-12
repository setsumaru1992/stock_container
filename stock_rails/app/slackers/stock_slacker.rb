class StockSlacker < PriceNoticeSlacker
  NO_VALUE = "--".freeze

  class << self
    def build_stock_slack_values(stock_price_values)
      stock_price_values.map do |stock_price_value|
        build_stock_slack_value(stock_price_value)
      end.compact
    end

    def build_stock_slack_value(stock_price_value)
      value = StockSlackValue.new
      code = stock_price_value.code
      value.stock_code = code
      value.stock_price_value = stock_price_value
      # ActiveRecordの直呼びはCQRSの観点から許容
      stock = ::Stock.find_by(code: code)
      if stock.present?
        value.stock = stock

        value.stock_condition = stock.stock_conditions.first
        value.stock_financial_condition = stock.stock_financial_conditions.first

        latest_paformances = stock.stock_performances.order("year DESC")&.take(2)
        value.stock_latest_performance = latest_paformances.first if latest_paformances.present? && latest_paformances.size >= 1
        value.stock_previous_performance = latest_paformances.second if latest_paformances.present? && latest_paformances.size >= 2

        value
      else
        value
      end
    rescue => e
      code = stock_price_value.code
      ErrorSlacker.new.notice_error(e)
      new.notice("(エラー発生)証券番号:#{code}の情報取得失敗")
      Rails.logger.warn(e)
      nil
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

  def notice_bought_stocks_with_chart(bought_stock_values)
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
  end

  def notice_favorite_stocks_with_chart(favorite_stock_values)
    notice("---- ポートフォリオ ----")
    favorite_stock_values
        .sort_by {|favorite_stock_value| favorite_stock_value.stock_price_value.price}.reverse
        .each do |value|
      begin
        if value.stock.present?
          notice_with_image(favorite_stock_message(value), parse_image_path_to_image_url(value.stock_price_value.chart_path))
        else
          notice_with_image(favorite_stock_message_without_stock_information(value), parse_image_path_to_image_url(value.stock_price_value.chart_path))
        end
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

    message = ""
    message << stock_heading(stock_value) + "\n"

    message << current_price_message(price, previous_price: ref_price) + "\n"
    message << increased_and_decreaced_price_message(price) + "\n"

    message << stock_url(stock_value.stock_code) + "\n\n"
    message << stock_detail_message(stock_value) + "\n"

    message
  end

  def favorite_stock_message(stock_value)
    price = stock_value.stock_price_value.price
    ref_price = stock_value.stock_price_value.reference_price

    message = ""
    message << stock_heading(stock_value) + "\n"

    message << <<-EOS
現在値: #{price.to_s(:delimited)}
前日: #{stock_value.stock_price_value.diff_price_from_previous_day}(前日比: #{stock_value.stock_price_value.rate_str_comparing_privious_day_price})
参考価格: #{ref_price}(利益: #{profit(ref_price, price)}(#{profit_rate(ref_price, price)}%))
    EOS

    message << increaced_price_message(price) + "\n"

    message << stock_url(stock_value.stock.code) + "\n\n"
    message << stock_detail_message(stock_value) + "\n"
    message
  end

  def stock_heading(stock_value)
    if stock_value.stock.present?
      "【#{stock_value.stock_code} #{stock_value.stock.name}】#{stock_is_nikkei_average_group(stock_value)}"
    else
      "【#{stock_value.stock_code}】"
    end
  end



  def stock_url(stock_code)
    "https://moyamoya.space/dailyutil/stockInfo/access2sbi_chart?stock_code=#{stock_code}"
  end

  def favorite_stock_message_without_stock_information(stock_value)
    price = stock_value.stock_price_value.price
    ref_price = stock_value.stock_price_value.reference_price
    <<-EOS
【#{stock_value.stock_code}】
(現在)#{price} (参考価格)#{ref_price}
(差分)#{profit(ref_price, price)}(#{profit_rate(ref_price, price)}%)
5%↑    #{by_percent_of(0.05, price)}
10%↑  #{by_percent_of(0.1, price)}
20%↑  #{by_percent_of(0.2, price)}
https://moyamoya.space/dailyutil/stockInfo/access2sbi_chart?stock_code=#{stock_value.stock_code}
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

  def by_percent_of(percent, target)
    return NO_VALUE unless percent.is_a?(Numeric) && target.is_a?(Numeric)
    target + (target * percent).round
  end

  def stock_detail_message(stock_value)
    return "" if stock_value.stock.blank?

    message = ""
    message << stock_feature(stock_value)
    message << stock_settlement_months(stock_value)
    message << stock_financial_message(stock_value)
    message
  end

  def stock_feature(stock_value)
    feature = stock_value.try(:stock_condition).try(:feature)
    return "" if feature.nil?
    "特徴：#{feature}\n\n"
  end

  def stock_is_nikkei_average_group(stock_value)
    is_nikkei_average_group = stock_value.try(:stock_financial_condition).try(:is_nikkei_average_group)
    return "" if is_nikkei_average_group.nil?
    return "" unless is_nikkei_average_group
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
    "決算：#{settlement_month}月(#{settlement_months.join(", ")}月)\n\n"
  end

  def stock_financial_message(stock_value)
    message = ""
    market_capitalization_str = "#{stock_value.stock_financial_condition.market_capitalization.to_s(:delimited)}百万円"

    message << "時価総額: #{market_capitalization_str}\n"
    pbr = (stock_value.stock_financial_condition.market_capitalization.fdiv(stock_value.stock_financial_condition.shareholder_equity)).round(1)
    message << "PBR(時価総額/純資産): #{pbr} \n"

    per = if stock_value.stock_latest_performance.present?
            stock_value.stock_financial_condition.market_capitalization.fdiv(stock_value.stock_latest_performance.net_income).round(1)
          else
            "-"
          end
    message << "PER(時価総額/そのQの予測純利益): #{per} \n"
    message << "※PBR,PERともに低いなら割安 \n\n"

    message << perfomance_message(stock_value.stock_latest_performance, stock_value.stock_previous_performance)

    message
  end

  def perfomance_message(performance, previous_performance)
    return "" if performance.blank?

    message = ""
    message << "#{performance.year}年業績(単位:百万円)\n"
    message << "(売上高)#{performance.net_sales.to_s(:delimited)} "
    message << "(#{profit_rate(previous_performance.net_sales, performance.net_sales)}%)" if previous_performance.present?
    message << "\n"
    message << "(営業利益)#{performance.operating_income.to_s(:delimited)} "
    message << "(#{profit_rate(previous_performance.operating_income, performance.operating_income)}%)" if previous_performance.present?
    message << "\n"
    message << "(経常利益)#{performance.ordinary_income.to_s(:delimited)} "
    message << "(#{profit_rate(previous_performance.ordinary_income, performance.ordinary_income)}%)" if previous_performance.present?
    message << "\n"
    message << "(純利益)#{performance.net_income.to_s(:delimited)}"
    message << "(#{profit_rate(previous_performance.net_income, performance.net_income)}%)" if previous_performance.present?
    message << "\n"
    message
  end
end
