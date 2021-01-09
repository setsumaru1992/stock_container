class BotApplicationService
  class << self
    def notice_bought_stock_prices(user_id)
      bought_stock_prices = ::StockDomain::Entity.get_bought_stock_prices(user_id)
      return if bought_stock_prices.empty?

      bought_stock_values = ::StockSlacker.build_stock_slack_values(bought_stock_prices)
      # TODO slackのWebhookURLをDBから取得する
      StockSlacker.new.notice_bought_stocks(bought_stock_values)
    rescue => e
      Rails.logger.error(e)
      ErrorSlacker.new.notice_error(e)
      StockSlacker.new.notice("notice_bought_stock_pricesでエラー発生")
      nil
    end

    def notice_bought_stocks_with_chart(user_id)
      bought_stock_prices = ::StockDomain::Entity.get_bought_stock_prices(user_id, need_chart: true)
      return if bought_stock_prices.empty?

      bought_stock_values = ::StockSlacker.build_stock_slack_values(bought_stock_prices)
      StockSlacker.new.notice_bought_stocks_with_chart(bought_stock_values)
    rescue => e
      Rails.logger.error(e)
      ErrorSlacker.new.notice_error(e)
      StockSlacker.new.notice("notice_bought_stocks_with_chartでエラー発生")
      nil
    end

    def notice_favorite_stocks_with_chart(user_id)
      favorite_stock_prices = ::StockDomain::Entity.get_favorite_stock_prices(user_id, need_chart: true)
      return if favorite_stock_prices.empty?

      favorite_stock_values = ::StockSlacker.build_stock_slack_values(favorite_stock_prices)
      StockSlacker.new.notice_favorite_stocks_with_chart(favorite_stock_values)
    rescue => e
      Rails.logger.error(e)
      ErrorSlacker.new.notice_error(e)
      StockSlacker.new.notice("notice_favorite_stocks_with_chartでエラー発生")
      nil
    end

    def notice_index_prices
      index_prices = ::IndexDomain::Entity.get_index_prices(need_chart: true)
      index_slack_values = ::IndexSlacker.build_index_slack_values(index_prices)
      IndexSlacker.new.notice_index_with_chart(index_slack_values)
    rescue => e
      Rails.logger.error(e)
      ErrorSlacker.new.notice_error(e)
      StockSlacker.new.notice("notice_index_pricesでエラー発生")
      nil
    end

    def notice_fx_prices
      fx_prices = ::FxDomain::Entity.get_fx_prices(need_chart: true)
      fx_slack_values = ::FxSlacker.build_fx_slack_values(fx_prices)
      FxSlacker.new.notice_fx_with_chart(fx_slack_values)
    rescue => e
      Rails.logger.error(e)
      ErrorSlacker.new.notice_error(e)
      StockSlacker.new.notice("notice_fx_pricesでエラー発生")
      nil
    end

    def update_fx_chart_image
      ::FxDomain::Entity.update_chart_image
    rescue => e
      Rails.logger.error(e)
      ErrorSlacker.new.notice_error(e)
      StockSlacker.new.notice("update_fx_chart_imageでエラー発生")
      nil
    end

    def notice_metal_prices
      metal_prices = ::MetalDomain::Entity.get_gold_price #(need_chart: true)
      metal_slack_values = ::MetalSlacker.build_metal_slack_values(metal_prices)
      MetalSlacker.new.notice_metal_with_chart(metal_slack_values)
    rescue => e
      Rails.logger.error(e)
      ErrorSlacker.new.notice_error(e)
      StockSlacker.new.notice("notice_metal_pricesでエラー発生")
      nil
    end
  end
end
