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

  def regist_stock_prices
    ::StockDomain::Entity.save_stock_prices
    render json: {
      status: "success"
    }
  end

  def notice_bought_stock_prices
    response = {
      status: "success"
    }
    bought_stock_prices = ::StockDomain::Entity.get_bought_stock_prices(user_id_from(bot_params[:api_key]))
    render json: response and return if bought_stock_prices.nil?
    StockSlacker.new.notice_bought_stocks(bought_stock_prices)
    render json: response
  end

  def notice_bought_and_favorite_stocks_with_chart
    response = {
      status: "success"
    }
    bought_stock_prices = ::StockDomain::Entity.get_bought_stock_prices(user_id_from(bot_params[:api_key]))
    favorite_stock_prices = ::StockDomain::Entity.get_favorite_stock_prices(user_id_from(bot_params[:api_key]))
    render json: response and return if bought_stock_prices.nil? && favorite_stock_prices.empty?
    StockSlacker.new.notice_bought_and_favorite_stocks_with_chart(bought_stocks: bought_stock_prices, favorite_stocks: favorite_stock_prices)
    render json: response
  end

  private

  def user_id_from(api_key)
    user = UserDomain::Factory.build_by_api_key(api_key)
    user.id
  end

  def bot_params
    params.permit(:api_key)
  end

  def rescue_error(e)
    ErrorSlacker.new.notice(e.to_s)
    raise e
  end
end