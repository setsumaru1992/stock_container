Rails.application.routes.draw do
  namespace :view do
    get 'stock_category/list'
  end
  root to: "bot#debug"
  devise_for :users, :controllers => {
    :registrations => 'users/registrations',
    :sessions => 'users/sessions'
  }

  namespace :bot do
    get    "regist_new_stocks"
    get    "regist_or_update_stocks"
    get    "regist_or_update_stock"
    get    "regist_stock_prices"
    get    "notice_bought_stock_prices"
    get    "notice_bought_and_favorite_stocks_with_chart"
  end

  namespace :view do
    get    "stock/search"
  end
end
