Rails.application.routes.draw do
  scope :stockapp do
    root to: "view/stock#base"

    namespace :view do
      get "stock", to: "stock#base"
      get "stock/favorite", to: "stock#favorite"
    end

    namespace :view do
      get 'stock_category/list'
    end

    get "debug/debug"

    devise_for :users, :controllers => {
      :registrations => 'users/registrations',
      :sessions => 'users/sessions'
    }

    namespace :bot do
      get "regist_new_stocks"
      get "regist_or_update_stocks"
      get "regist_or_update_stock"
      get "regist_stock_prices"
      get "regist_stock_mean_prices"
      get "regist_stock_charts"
      get "notice_bought_stock_prices"
      get "notice_bought_and_favorite_stocks_with_chart"
      get "notice_index_prices"
      get "notice_important_prices"
    end
  end
end
