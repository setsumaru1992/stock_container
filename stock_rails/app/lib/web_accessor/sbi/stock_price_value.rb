module WebAccessor::Sbi
  class StockPriceValue
    include Concerns::Hashable

    attr_accessor :code,
                  :price
  end
end