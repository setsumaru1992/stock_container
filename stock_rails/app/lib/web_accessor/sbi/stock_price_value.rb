module WebAccessor::Sbi
  class StockPriceValue
    include Concerns::Hashable

    attr_accessor :code,
                  :price,
                  :reference_price,
                  :chart_path,
                  :diff_price_from_previous_day,
                  :rate_str_comparing_privious_day_price
  end
end