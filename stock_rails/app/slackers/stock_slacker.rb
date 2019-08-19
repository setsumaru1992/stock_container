class StockSlacker < ApplicationSlacker

  def notice_bought_stocks(bought_stocks)
    notice("TODO Railsアプリでnotice_bought_stocks実装")
  end

  def notice_bought_and_favorite_stocks_with_chart(bought_stocks: nil, favorite_stocks: nil)
    notice("TODO Railsアプリでnotice_bought_and_favorite_stocks_with_chart実装")
  end

  private

  def webhook_url
    ENV["STOCK_SLACK_WEBHOOK_URL"]
  end
end