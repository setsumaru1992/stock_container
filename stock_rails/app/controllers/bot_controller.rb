class BotController < ApplicationController
  def regist_new_stocks
    ::StockDomain::Entity.save_stocks_info
    render json: {
      status: "success"
    }
  end
end