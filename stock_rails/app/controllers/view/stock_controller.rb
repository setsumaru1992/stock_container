class View::StockController < ApplicationController
  ORDER_MAP = {
    code: {
      asc: "code ASC",
      desc: "code DESC"
    },
    market_capitalization: {
      asc: "market_capitalization ASC",
      desc: "market_capitalization DESC"
    },
    price: {
      asc: "price ASC",
      desc: "price DESC"
    },
    category: {
      asc: "category ASC, category_rank ASC",
      desc: "category ASC, category_rank DESC"
    },
    listed_year: {
      asc: "listed_year ASC",
      desc: "listed_year DESC"
    }
  }

  def search
    @order = params[:order] || ""
    @only_nikkei225 = params[:only_nikkei225] || "off"

    conditions = {}
    if @only_nikkei225 == "on"
      conditions[:stock_financial_conditions] ||= {}
      conditions[:stock_financial_conditions][:is_nikkei_average_group] = true
    end

    order = parse_order_param
    @current_price_day = StockPrice.last.day
    @stocks = Stock
                .joins("LEFT OUTER JOIN stock_conditions ON stocks.id = stock_conditions.stock_id")
                .joins("LEFT OUTER JOIN stock_financial_conditions ON stocks.id = stock_financial_conditions.stock_id")
                .joins("LEFT OUTER JOIN stock_performances ON stocks.id = stock_performances.stock_id AND stock_performances.year = #{Date.today.year}")
                .joins("LEFT OUTER JOIN stock_prices ON stocks.id = stock_prices.stock_id AND stock_prices.day = '#{@current_price_day}'")
                .where(conditions)
                .order(order)
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
    @parameter_example = @stocks.first
  end

  private

  def parse_order_param
    order_param_str = params[:order]
    return ORDER_MAP[:code][:asc] if order_param_str.blank?
    order_param_str.split(",").map do |order_param|
      order_col = order_param.slice(0..-2).to_sym
      order_type = order_param.slice(-1) == "2" ? :desc : :asc
      ORDER_MAP[order_col][order_type]
    end.join(",")
  end
end
