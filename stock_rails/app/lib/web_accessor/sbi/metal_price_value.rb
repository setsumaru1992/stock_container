module WebAccessor::Sbi
  class MetalPriceValue
    include Concerns::Hashable

    attr_accessor :code,
                  :buy_price,
                  :diff_buy_price_from_previous_day,
                  :sell_price,
                  :diff_sell_price_from_previous_day,
                  :reference_price,
                  :chart_path

    def buy_price_of_previous_day
      buy_price - diff_buy_price_from_previous_day
    end

    def sell_price_of_previous_day
      sell_price - diff_sell_price_from_previous_day
    end
  end
end
