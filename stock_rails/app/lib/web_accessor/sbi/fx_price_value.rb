module WebAccessor::Sbi
  class FxPriceValue
    include Concerns::Hashable

    attr_accessor :code,
                  :price,
                  :reference_price,
                  :chart_path
  end
end