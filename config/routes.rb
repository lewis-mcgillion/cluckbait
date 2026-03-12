Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  root "home#index"

  resources :chicken_shops, only: [ :index, :show ] do
    resources :reviews, only: [ :create, :destroy ]
  end

  resources :profiles, only: [ :show, :edit, :update ], param: :id

  resources :friendships, only: [ :index, :create, :update, :destroy ]

  resources :conversations, only: [ :index, :show, :create ] do
    resources :messages, only: [ :create ]
  end

  resources :notifications, only: [ :index ] do
    member do
      patch :mark_as_read
    end
    collection do
      post :mark_all_as_read
    end
  end

  # API endpoints for map
  get "api/shops", to: "api/shops#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
