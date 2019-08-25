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
    },
    net_sales_profit_rate: {
      asc: "net_sales_profit_rate ASC",
      desc: "net_sales_profit_rate DESC"
    },
    operating_income_profit_rate: {
      asc: "operating_income_profit_rate ASC",
      desc: "operating_income_profit_rate DESC"
    },
    ordinary_income_profit_rate: {
      asc: "ordinary_income_profit_rate ASC",
      desc: "ordinary_income_profit_rate DESC"
    },
    net_income_profit_rate: {
      asc: "net_income_profit_rate ASC",
      desc: "net_income_profit_rate DESC"
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
    @latest_first_year = StockPerformance.order("year DESC").first.year
    @current_price_day = StockPrice.last.day
    @stocks = Stock
                .joins("LEFT OUTER JOIN stock_conditions ON stocks.id = stock_conditions.stock_id")
                .joins("LEFT OUTER JOIN stock_financial_conditions ON stocks.id = stock_financial_conditions.stock_id")
                .joins("LEFT OUTER JOIN stock_performances ON stocks.id = stock_performances.stock_id AND stock_performances.year = #{Date.today.year}")
                .joins("LEFT OUTER JOIN stock_prices ON stocks.id = stock_prices.stock_id AND stock_prices.day = '#{@current_price_day}'")
                .joins("LEFT OUTER JOIN stock_performances AS latest_performances ON stocks.id = latest_performances.stock_id AND latest_performances.year = '#{@latest_first_year}'")
                .joins("LEFT OUTER JOIN stock_performances AS ref_performances ON stocks.id = ref_performances.stock_id AND ref_performances.year = '#{@latest_first_year - 1}'")
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

                , latest_performances.net_sales AS latest_net_sales
                , ref_performances.net_sales AS ref_net_sales
                , (CASE
                    WHEN latest_performances.net_sales IS NOT NULL AND ref_performances.net_sales IS NOT NULL
                      THEN ((latest_performances.net_sales - ref_performances.net_sales) / ABS(ref_performances.net_sales)) * 100
                    ELSE NULL
                  END) AS net_sales_profit_rate

                , latest_performances.operating_income AS latest_operating_income
                , ref_performances.operating_income AS ref_operating_income
                , (CASE
                    WHEN latest_performances.operating_income IS NOT NULL AND ref_performances.operating_income IS NOT NULL
                      THEN ((latest_performances.operating_income - ref_performances.operating_income) / ABS(ref_performances.operating_income)) * 100
                    ELSE NULL
                  END) AS operating_income_profit_rate

                , latest_performances.ordinary_income AS latest_ordinary_income
                , ref_performances.ordinary_income AS ref_ordinary_income
                , (CASE
                    WHEN latest_performances.ordinary_income IS NOT NULL AND ref_performances.ordinary_income IS NOT NULL
                      THEN ((latest_performances.ordinary_income - ref_performances.ordinary_income) / ABS(ref_performances.ordinary_income)) * 100
                    ELSE NULL
                  END) AS ordinary_income_profit_rate

                , latest_performances.net_income AS latest_net_income
                , ref_performances.net_income AS ref_net_income
                , (CASE
                    WHEN latest_performances.net_income IS NOT NULL AND ref_performances.net_income IS NOT NULL
                      THEN ((latest_performances.net_income - ref_performances.net_income) / ABS(ref_performances.net_income)) * 100
                    ELSE NULL
                  END) AS net_income_profit_rate
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
