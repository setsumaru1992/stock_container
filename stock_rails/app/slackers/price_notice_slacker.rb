class PriceNoticeSlacker < ApplicationSlacker
  private

  def current_price_message(cur_price, previous_price: nil, cur_price_label: nil)
    cur_price_label ||= "現在値"
    message = ""
    message << "#{cur_price_label}: #{cur_price.to_s(:delimited)}"
    if previous_price.present?
      message << "(前日: #{previous_price.to_s(:delimited)} #{profit_rate(previous_price, cur_price)}%)"
    end
    message
  end

  def increaced_price_message(cur_price)
    <<-EOS
  0%:  #{cur_price.to_s(:delimited)}
  5%:  #{by_percent_of(0.05, cur_price).to_s(:delimited)}
10%:  #{by_percent_of(0.1, cur_price).to_s(:delimited)}
20%:  #{by_percent_of(0.2, cur_price).to_s(:delimited)}
    EOS
  end

  def increased_and_decreaced_price_message(cur_price)
    <<-EOS
5%↑    #{by_percent_of(0.05, cur_price).to_s(:delimited)}  5%↓    #{by_percent_of(-0.05, cur_price).to_s(:delimited)}
10%↑  #{by_percent_of(0.1, cur_price).to_s(:delimited)}  10%↓  #{by_percent_of(-0.1, cur_price).to_s(:delimited)}
20%↑  #{by_percent_of(0.2, cur_price).to_s(:delimited)}  20%↓  #{by_percent_of(-0.2, cur_price).to_s(:delimited)}
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

  def by_percent_of(percent, target, digit: 0)
    return NO_VALUE unless percent.is_a?(Numeric) && target.is_a?(Numeric)
    (target + (target * percent).round(digit)).round(digit)
  end
end