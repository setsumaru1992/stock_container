Rails.application.routes.draw do
  root to: "bot/debug#debug"
  devise_for :users, :controllers => {
    :registrations => 'users/registrations',
    :sessions => 'users/sessions'
  }

  namespace :bot do
    get    "regist_new_stocks"
    get    "regist_or_update_stocks"
    get    "regist_stock_prices"
    get    "notice_bought_stock_prices"
    get    "notice_bought_and_favorite_stocks_with_chart"
  end
end
