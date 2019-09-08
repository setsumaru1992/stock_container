class View::StockController < ApplicationController
  def base
    @order = params[:order] || ""
    @category = params[:category] || ""
    @only_nikkei225 = params[:only_nikkei225] || "off"

    conditions = {}
    if @only_nikkei225 == "on"
      conditions[:stock_financial_conditions] ||= {}
      conditions[:stock_financial_conditions][:is_nikkei_average_group] = true
    end

    if @category.present?
      conditions[:stocks] ||= {}
      conditions[:stocks][:category] = @category
    end

    order = parse_order_param(params[:order], order_hash[:code][:asc])
    @latest_first_year = StockPerformance.order("year DESC").first.year
    @current_price_day = StockPrice.last.day
    @stock_paginator, @stocks = StockDomain::Query.base_stock_info(conditions, order, @current_price_day, @latest_first_year, params[:page])

    @parameter_example = @stocks.first
    @categories = Stock.select("DISTINCT category").map(&:category)
  end

  def chart
    @order = params[:order] || ""
    @category = params[:category] || ""
    @category = params[:category] || ""
    @only_nikkei225 = params[:only_nikkei225] || "off"

    conditions = {}
    if @only_nikkei225 == "on"
      conditions[:stock_financial_conditions] ||= {}
      conditions[:stock_financial_conditions][:is_nikkei_average_group] = true
    end

    if @category.present?
      conditions[:stocks] ||= {}
      conditions[:stocks][:category] = @category
    end

    order = parse_order_param(params[:order], order_hash[:day_of_week_golden_cross][:desc])
    @latest_chart_day = StockChart.order("day DESC").first.day
    range_type = params[:range_type] || StockChart::RANGE_TYPE_HASH[StockChart::FIVE_YEAR]
    @stock_paginator, @stocks = StockDomain::Query.chart(conditions, order, @latest_chart_day, range_type, params[:page])

    @parameter_example = @stocks.first
    @categories = Stock.select("DISTINCT category").map(&:category)
  end

  private

  def parse_order_param(order_params, default_order)
    return default_order if order_params.blank?
    order_params.split(",").map do |order_param|
      order_col = order_param.slice(0..-2).to_sym
      order_type = order_param.slice(-1) == "2" ? :desc : :asc
      order_hash[order_col][order_type]
    end.join(",")
  end

  def order_hash
    {
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
        asc: "category ASC",
        desc: "category DESC"
      },
      category_rank: {
        asc: "category ASC, category_rank ASC",
        desc: "category ASC, category_rank DESC"
      },
      listed_year: {
        asc: "listed_year ASC, listed_month ASC",
        desc: "listed_year DESC, listed_month DESC"
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
      },
      day_of_day_golden_cross: {
        asc: "day_of_day_golden_cross ASC, day_of_week_golden_cross ASC, day_of_day_dead_cross ASC, day_of_week_dead_cross ASC",
        desc: "day_of_day_golden_cross DESC, day_of_week_golden_cross DESC, day_of_day_dead_cross DESC, day_of_week_dead_cross DESC"
      },
      day_of_day_dead_cross: {
        asc: "day_of_day_dead_cross ASC, day_of_week_dead_cross ASC, day_of_day_golden_cross ASC, day_of_week_golden_cross ASC",
        desc: "day_of_day_dead_cross DESC, day_of_week_dead_cross DESC, day_of_day_golden_cross DESC, day_of_week_golden_cross DESC"
      },
      day_of_week_golden_cross: {
        asc: "day_of_week_golden_cross ASC, day_of_day_golden_cross ASC, day_of_day_dead_cross ASC, day_of_week_dead_cross ASC",
        desc: "day_of_week_golden_cross DESC, day_of_day_golden_cross DESC, day_of_day_dead_cross DESC, day_of_week_dead_cross DESC"
      },
      day_of_week_dead_cross: {
        asc: "day_of_week_dead_cross ASC, day_of_day_dead_cross ASC, day_of_day_golden_cross ASC, day_of_week_golden_cross ASC",
        desc: "day_of_week_dead_cross DESC, day_of_day_dead_cross DESC, day_of_day_golden_cross DESC, day_of_week_golden_cross DESC"
      },
      per: {
        asc: "per ASC",
        desc: "per DESC"
      },
      pbr: {
        asc: "pbr ASC",
        desc: "pbr DESC"
      }
    }
  end
end
