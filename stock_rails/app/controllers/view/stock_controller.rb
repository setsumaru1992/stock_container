class View::StockController < ApplicationController
  def search
    @current_price_day = StockPrice.last.day
    @stocks = Stock
                .joins("LEFT OUTER JOIN stock_conditions ON stocks.id = stock_conditions.stock_id")
                .joins("LEFT OUTER JOIN stock_financial_conditions ON stocks.id = stock_financial_conditions.stock_id")
                .joins("LEFT OUTER JOIN stock_performances ON stocks.id = stock_performances.stock_id AND stock_performances.year = #{Date.today.year}")
                .joins("LEFT OUTER JOIN stock_prices ON stocks.id = stock_prices.stock_id AND stock_prices.day = '#{@current_price_day}'")
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
                , stock_prices.price
                ").map { |stock| stock.attributes}
  end
end
