Rails.application.routes.draw do
  root to: "bot/debug#debug"
  devise_for :users, :controllers => {
    :registrations => 'users/registrations',
    :sessions => 'users/sessions'
  }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :bot do
    namespace :debug do
      root action: :debug
    end
  end
end
