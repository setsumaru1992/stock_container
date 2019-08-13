module WebAccessor::Sbi
  class StockDetailValues
    include Concerns::Hashable

    attr_accessor :settlement_month, :established_year, :listed_year, :listed_month,
                 :feature, :trend, :current_strategy, :category, :category_rank, :big_stock_holder

  end
end