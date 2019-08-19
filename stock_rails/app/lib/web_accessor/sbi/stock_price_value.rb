module WebAccessor::Sbi
  class StockPriceValue
    include Concerns::Hashable

    attr_accessor :stock_code,
                  :price
  end
end