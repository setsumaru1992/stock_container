module WebAccessor::Sbi
  class IndexPriceValue
    include Concerns::Hashable

    attr_accessor :code,
                  :price,
                  :reference_price,
                  :chart_path
  end
end