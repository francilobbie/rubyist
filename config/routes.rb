Rails.application.routes.draw do
  get 'dashboard/show'
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "posts#index"
  resources :posts, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    resources :comments, only: [:create, :edit, :update, :destroy] do
      resources :likes, only: [:create, :destroy], defaults: { likeable: 'Comment' }
      resources :replies, controller: 'comments', only: [:create, :edit, :update, :destroy]
    end
    resources :likes, only: [:create, :destroy], defaults: { likeable: 'Post' }
    resource :save_post, only: [:create, :destroy], as: :save, path: 'save'
  end

  patch '/posts/:id/unpublish', to: 'posts#unpublish', as: :unpublish_post

  resources :users, only: [:show, :edit, :update] do
    member do
      get :posts  # This route allows users to manage their posts
      get :saved_posts # This route allows users to view their saved posts
    end
    resource :profile, only: [:show, :edit, :update]
  end

  delete "/tags/:id", to: "tags#destroy", as: :tag
  resources :maps

  authenticated :user do
    root 'dashboard#show', as: :authenticated_root
  end

  namespace :admin do
    # put your admin routes here
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

  resources :reports, only: [:index, :show, :edit, :update, :destroy, :new, :create] do
    member do
      delete 'destroy_comment'
    end
  end

  get 'moderation', to: 'moderation#index'

  get "up" => "rails/health#show", as: :rails_health_check
end
