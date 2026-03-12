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

  resources :activities, only: [ :index ]

  resources :conversations, only: [ :index, :show, :create ] do
    resources :messages, only: [ :create ]
  end

  # API endpoints for map
  get "api/shops", to: "api/shops#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
