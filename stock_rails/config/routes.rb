Rails.application.routes.draw do
  root to: "bot/debug#debug"
  devise_for :users, :controllers => {
    :registrations => 'users/registrations',
    :sessions => 'users/sessions'
  }

  namespace :bot do
    get    "regist_new_stocks"
  end
end
