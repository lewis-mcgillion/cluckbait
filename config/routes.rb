Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    passwords: "users/passwords"
  }

  root "home#index"

  resources :chicken_shops, only: [:index, :show, :new, :create] do
    resources :reviews, only: [:create, :destroy]
  end

  resources :reviews, only: [] do
    resources :reactions, only: [:create], controller: "review_reactions"
  end

  resources :profiles, only: [:show, :edit, :update], param: :id

  resources :wishlist_items, only: [:index, :create, :update, :destroy]

  resources :friendships, only: [:index, :create, :update, :destroy]

  resources :activities, only: [:index]

  resources :conversations, only: [:index, :show, :create] do
    resources :messages, only: [:create]
  end

  resources :notifications, only: [:index] do
    member do
      patch :mark_as_read
    end
    collection do
      post :mark_all_as_read
    end
  end

  get "api/shops", to: "api/shops#index"

  # Fallback for sign-out via GET (when JS/Turbo is unavailable)
  get "users/sign_out", to: redirect("/")

  get "up" => "rails/health#show", :as => :rails_health_check
end
