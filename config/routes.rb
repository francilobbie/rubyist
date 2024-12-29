Rails.application.routes.draw do
  get 'dashboard/show'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # root "posts#index"

  # Root route
  root "render#index"

  resources :posts, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    resources :comments, only: [:create, :edit, :update, :destroy] do
      resources :likes, only: [:create, :destroy], defaults: { likeable: 'Comment' }
      resources :replies, controller: 'comments', only: [:create, :edit, :update, :destroy]
    end
    resources :likes, only: [:create, :destroy], defaults: { likeable: 'Post' }
    resource :save_post, only: [:create, :destroy], as: :save, path: 'save'
  end

  patch '/posts/:id/unpublish', to: 'posts#unpublish', as: :unpublish_post

  get 'signup', to: 'users#new', as: 'signup'

  resources :users, only: [:show, :edit, :update] do
    member do
      get :posts  # This route allows users to manage their posts
      get :saved_posts # This route allows users to view their saved posts
    end
    resource :profile, only: [:show, :edit, :update]
    resources :donations, only: [:index], module: :users
  end

  delete "/tags/:id", to: "tags#destroy", as: :tag
  resources :maps

  authenticated :user do
    root 'dashboard#show', as: :authenticated_root
  end

  namespace :admin do
    # put your admin routes here
    get 'dashboard/weekly_donations', to: 'dashboard#weekly_donations'
    root to: "dashboard#index" # Example admin dashboard route
    resources :users do
      collection do
        get 'search'
      end
      member do
        patch :suspend
        patch :unsuspend
        delete :destroy
      end
    end
    resources :posts, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  end

  resources :series, only: [:index, :new, :create, :edit, :update, :show]


  resources :reports, only: [:index, :show, :edit, :update, :destroy, :new, :create] do
    member do
      delete 'destroy_comment'
    end
  end

  get 'moderation', to: 'moderation#index'

  get "up" => "rails/health#show", as: :rails_health_check

  resources :notifications, only: [:index, :destroy] do
    member do
      patch :mark_as_read
    end
  end

  resources :donations, only: [:new, :create]
  post 'webhooks/stripe', to: 'webhooks#stripe'

  resources :donations do
    collection do
      get 'success'
      get 'cancel'
    end
  end

  resources :feedbacks, only: [:new, :create]


  post 'newsletter/subscribe', to: 'newsletters#subscribe', as: 'newsletter_subscribe'
  get 'newsletter/unsubscribe', to: 'newsletters#confirm_unsubscribe', as: 'confirm_unsubscribe_newsletter'
  delete 'newsletter/unsubscribe', to: 'newsletters#unsubscribe', as: 'unsubscribe_newsletter'

end
