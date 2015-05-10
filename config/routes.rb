Rails.application.routes.draw do
  # resources :twitter_follow_preferences
  # resources :twitter_follows
  # resources :users
  require "sidekiq/web"

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?

  mount Sidekiq::Web, at: "/sidekiq"


  root to: 'pages#index'

  get '/dashboard' => 'pages#dashboard'

  get "/auth/:provider/callback" => "sessions#create"
  get "/logout" => "sessions#destroy", :as => :signout

end
