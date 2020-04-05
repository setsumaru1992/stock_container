class BotController < ApplicationController

  rescue_from StandardError, with: :rescue_error

  def regist_new_stocks
    ::StockDomain::Entity.save_stock_informations
    render json: default_responce
  end

  def regist_or_update_stocks
    ::StockDomain::Entity.save_stock_informations(ignore_existing_stock_code: false)
    render json: default_responce
  end

  def regist_or_update_stock
    code = bot_params[:code].try(&:to_i)
    raise "Please send stock code." if code.nil?

    ::StockDomain::Entity.new(code).save_stock_information
    render json: default_responce
  end

  def regist_stock_prices
    ::StockDomain::Entity.save_stock_prices
    render json: default_responce
  end

  def regist_stock_mean_prices
    ::StockDomain::Entity.save_stock_mean_prices
    render json: default_responce
  end

  def regist_stock_charts
    ::StockDomain::Entity.save_stock_charts
    render json: default_responce
  end

  def notice_important_prices
    response = default_responce
    BotApplicationService.notice_index_prices
    BotApplicationService.notice_fx_prices
    BotApplicationService.notice_metal_prices
    render json: response
  end

  def notice_index_prices
    response = default_responce
    BotApplicationService.notice_index_prices
    render json: response
  end

  def notice_bought_stock_prices
    response = default_responce
    BotApplicationService.notice_bought_stock_prices(user_id_from(bot_params[:api_key]))
    render json: response
  end

  def notice_bought_and_favorite_stocks_with_chart
    response = default_responce
    BotApplicationService.notice_bought_stocks_with_chart(user_id_from(bot_params[:api_key]))
    BotApplicationService.notice_favorite_stocks_with_chart(user_id_from(bot_params[:api_key]))
    render json: response
  end

  private

  def user_id_from(api_key)
    user = UserDomain::Factory.build_by_api_key(api_key)
    user.id
  end

  def default_responce
    {
        status: "success"
    }
  end

  def bot_params
    params.permit(:api_key, :code)
  end

  def rescue_error(e)
    ErrorSlacker.new.notice(e)
    raise e
  end
end
