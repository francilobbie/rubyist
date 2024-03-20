Rails.application.routes.draw do
  get 'dashboard/show'
  get 'moderation/index'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "posts#index"
  resources :posts, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end
  # config/routes.rb
  resources :reports, only: [:new, :create]

  delete "/tags/:id", to: "tags#destroy", as: :tag
  # get "/page/map", to: "pages#map", as: :map
  resources :maps

  authenticated :user do
    root 'dashboard#show', as: :authenticated_root
  end

  namespace :admin do
    # put your admin routes here
    root to: "dashboard#index" # Example admin dashboard route
    resources :users
    resources :posts
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

end
