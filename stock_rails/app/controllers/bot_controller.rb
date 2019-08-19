class BotController < ApplicationController
  def regist_new_stocks
    ::StockDomain::Entity.save_stocks_info
    render json: {
      status: "success"
    }
  end

  def regist_or_update_stocks
    ::StockDomain::Entity.save_stocks_info(ignore_existing_stock_code: false)
    render json: {
      status: "success"
    }
  end

  def regist_stock_prices
    ::StockDomain::Entity.save_price_of_stocks
    render json: {
      status: "success"
    }
  end
end