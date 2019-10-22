class BotController < ApplicationController

  rescue_from StandardError, with: :rescue_error

  def regist_new_stocks
    ::StockDomain::Entity.save_stock_informations
    render json: {
      status: "success"
    }
  end

  def regist_or_update_stocks
    ::StockDomain::Entity.save_stock_informations(ignore_existing_stock_code: false)
    render json: {
      status: "success"
    }
  end

  def regist_or_update_stock
    code = bot_params[:code].try(&:to_i)
    raise "Please send stock code." if code.nil?

    ::StockDomain::Entity.new(code).save_stock_information
    render json: {
      status: "success"
    }
  end

  def regist_stock_prices
    ::StockDomain::Entity.save_stock_prices
    render json: {
      status: "success"
    }
  end

  def regist_stock_mean_prices
    ::StockDomain::Entity.save_stock_mean_prices
    render json: {
      status: "success"
    }
  end

  def regist_stock_charts
    ::StockDomain::Entity.save_stock_charts
    render json: {
      status: "success"
    }
  end

  def notice_index_prices
    response = {
      status: "success"
    }
    index_prices = ::IndexDomain::Entity.get_index_prices(need_chart: true)
    index_slack_values = index_prices.map do |index_price|
      ::IndexSlacker.build_index_slack_value(index_price)
    end
    IndexSlacker.new.notice_index_with_chart(index_slack_values)
    render json: response
  end

  def notice_bought_stock_prices
    response = {
      status: "success"
    }
    bought_stock_prices = ::StockDomain::Entity.get_bought_stock_prices(user_id_from(bot_params[:api_key]))
    return render json: response if bought_stock_prices.empty?

    bought_stock_values = bought_stock_prices.map do |stock_price_value|
      ::StockSlacker.build_stock_slack_value(stock_price_value)
    end
    # TODO slackのWebhookURLをDBから取得する
    StockSlacker.new.notice_bought_stocks(bought_stock_values)
    render json: response
  end

  def notice_bought_and_favorite_stocks_with_chart
    response = {
      status: "success"
    }
    bought_stock_prices = ::StockDomain::Entity.get_bought_stock_prices(user_id_from(bot_params[:api_key]), need_chart: true)
    favorite_stock_prices = ::StockDomain::Entity.get_favorite_stock_prices(user_id_from(bot_params[:api_key]), need_chart: true)

    return render json: response if bought_stock_prices.empty? && favorite_stock_prices.empty?

    bought_stock_values = bought_stock_prices.map do |stock_price_value|
      ::StockSlacker.build_stock_slack_value(stock_price_value)
    end
    favorite_stock_values = favorite_stock_prices.map do |stock_price_value|
      ::StockSlacker.build_stock_slack_value(stock_price_value)
    end
    StockSlacker.new.notice_bought_and_favorite_stocks_with_chart(favorite_stock_values, bought_stock_values)
    render json: response
  end

  private

  def user_id_from(api_key)
    user = UserDomain::Factory.build_by_api_key(api_key)
    user.id
  end

  def bot_params
    params.permit(:api_key, :code)
  end

  def rescue_error(e)
    ErrorSlacker.new.notice(e)
    raise e
  end
end