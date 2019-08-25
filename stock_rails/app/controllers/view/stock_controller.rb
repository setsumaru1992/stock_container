class View::StockController < ApplicationController
  def search
    @stocks = Stock
                .joins("LEFT OUTER JOIN stock_conditions ON stocks.id = stock_conditions.stock_id")
                .joins("LEFT OUTER JOIN stock_financial_conditions ON stocks.id = stock_financial_conditions.stock_id")
                .joins("LEFT OUTER JOIN stock_financial_conditions ON stocks.id = stock_financial_conditions.stock_id")
                .select("
                stocks.id
                , stocks.code
                , stocks.name
                , stocks.category
                , stocks.listed_year
                , stock_conditions.feature
                , stock_conditions.category_rank
                , stock_financial_conditions.market_capitalization
                , stock_financial_conditions.is_nikkei_average_group
                ").map { |stock| stock.attributes}
  end
end
