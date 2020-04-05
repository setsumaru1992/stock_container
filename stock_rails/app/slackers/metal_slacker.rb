class MetalSlacker < PriceNoticeSlacker
  NO_VALUE = "--".freeze

  class << self
    def build_metal_slack_values(metal_price_values)
      metal_price_values.map do |metal_price|
        build_metal_slack_value(metal_price)
      end.compact
    end

    def build_metal_slack_value(metal_price_value)
      value = MetalSlackValue.new
      value.metal_price_value = metal_price_value
      value
    rescue => e
      ErrorSlacker.new.notice_error(e)
      notice("(エラー発生)金の情報取得失敗")
      Rails.logger.warn(e)
      nil
    end
  end

  def notice_metal_with_chart(metal_values)
    metal_values.each do |value|
      begin
        notice_with_image(metal_message(value), "https://kibotsu-stock-images.s3-ap-northeast-1.amazonaws.com/gold_chart.png")
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

  def metal_message(value)
    v = value.metal_price_value
    message = ""

    message << <<-EOS
【金】
#{current_price_message(v.buy_price, previous_price: v.buy_price_of_previous_day, cur_price_label: "購入価格")}
#{current_price_message(v.sell_price, previous_price: v.sell_price_of_previous_day, cur_price_label: "売却価格")}
    EOS

    if v.reference_price == 0
      message << "\n"
      message << <<-EOS
(今買った場合の利益毎の売却価格)
#{increaced_price_message(v.buy_price)}
      EOS
    else
      message << <<-EOS
参考価格 #{v.reference_price.to_s(:delimited)} 
(現在の売却益: #{(v.sell_price - v.reference_price).to_s(:delimited)}(#{profit_rate(v.reference_price, v.sell_price)}%))

(目標売却益率毎の売却価格)
#{increaced_price_message(v.reference_price)}
      EOS
    end

    message << "#{metal_price_page_url}\n"
    message << "以下チャートについて\n"
    message << "- 単位は1トロイオンス(31.1035g)あたりのドル価格\n"
    message << "#{v.buy_price}(現在購入価格) * 31 / 105(ドル) = #{(v.buy_price * (31.fdiv(105))).round(2)}\n"
    message << "  つまり日本価格の1/3(=31/105)くらいがチャートの価格\n"
    message << "- 2020/04/06の参考用のスナップショット。チャート取得ロジックを作って定期更新するようにする\n"
    message
  end

  def metal_price_page_url
    "https://chartpark.com/gold.html"
  end

end