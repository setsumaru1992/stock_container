module WebAccessor::Sbi
  class StockPerformanceValue
    include Concerns::Hashable

    attr_accessor :year,
                  :month,
                  :net_sales, # 売上高
                  :operating_income, # 営業利益
                  :ordinary_income, # 経常利益
                  :net_income # 純利益
  end
end