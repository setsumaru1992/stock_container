class BotApplicationService
  class << self
    def notice_bought_stock_prices(user_id)
      bought_stock_prices = ::StockDomain::Entity.get_bought_stock_prices(user_id)
      return if bought_stock_prices.empty?

      bought_stock_values = ::StockSlacker.build_stock_slack_values(bought_stock_prices)
      # TODO slackのWebhookURLをDBから取得する
      StockSlacker.new.notice_bought_stocks(bought_stock_values)
    end

    def notice_bought_stocks_with_chart(user_id)
      bought_stock_prices = ::StockDomain::Entity.get_bought_stock_prices(user_id, need_chart: true)
      return if bought_stock_prices.empty?

      bought_stock_values = ::StockSlacker.build_stock_slack_values(bought_stock_prices)
      StockSlacker.new.notice_bought_stocks_with_chart(bought_stock_values)
    end

    def notice_favorite_stocks_with_chart(user_id)
      favorite_stock_prices = ::StockDomain::Entity.get_favorite_stock_prices(user_id, need_chart: true)
      return if favorite_stock_prices.empty?

      favorite_stock_values = ::StockSlacker.build_stock_slack_values(favorite_stock_prices)
      StockSlacker.new.notice_favorite_stocks_with_chart(favorite_stock_values)
    end

    def notice_index_prices
      index_prices = ::IndexDomain::Entity.get_index_prices(need_chart: true)
      index_slack_values = ::IndexSlacker.build_index_slack_values(index_prices)
      IndexSlacker.new.notice_index_with_chart(index_slack_values)
    end
  end
end
