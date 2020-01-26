class View::StockController < ApplicationController
  def base
    @order = params[:order] || ""
    @category = params[:category] || ""
    @only_nikkei225 = params[:only_nikkei225] || "off"
    @only_favorite = params[:only_favorite] || "off"
    @search_word = params[:search_word] || ""

    conditions = {}
    not_condition = {}
    condition_or_strs = []
    if @only_nikkei225 == "on"
      conditions[:stock_financial_conditions] ||= {}
      conditions[:stock_financial_conditions][:is_nikkei_average_group] = true
    end

    if @only_favorite == "on"
      not_condition[:stock_favorites] ||= {}
      not_condition[:stock_favorites][:id] = nil
    end

    if @category.present?
      conditions[:stocks] ||= {}
      conditions[:stocks][:category] = @category
    end

    if @search_word.present?
      condition_or_strs.push("stocks.code LIKE '%#{@search_word}%'")
      condition_or_strs.push("stocks.name LIKE '%#{@search_word}%'")
      condition_or_strs.push("stock_conditions.feature LIKE '%#{@search_word}%'")
    end

    order = parse_order_param(params[:order], order_hash[:code][:asc])
    @latest_first_year = StockPerformance.order("year DESC").first.year
    @current_price_day = StockPrice.last.day
    @latest_chart_day = StockChart.order("day DESC").first.day
    range_type = params[:range_type] || StockChart::RANGE_TYPE_HASH[StockChart::FIVE_YEAR]
    @stock_paginator, @stocks = StockDomain::Query.base_stock_info(
        conditions, not_condition, condition_or_strs, order, @current_price_day,
        @latest_first_year, @latest_chart_day, range_type, params[:page]
    )

    @parameter_example = @stocks.first
    @categories = Stock.select("DISTINCT category").map(&:category)
  end

  def favorite
    redirect_to request.referer
    id = params[:stock_id]&.to_i
    stock_favorite_dao = Stock.find(id).stock_favorites
    exist_stock_favorite = stock_favorite_dao.first
    if params[:favorite] == "1"
      return if exist_stock_favorite.present?
      stock_favorite_dao.new.save
    else
      return if exist_stock_favorite.blank?
      exist_stock_favorite.destroy
    end
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
