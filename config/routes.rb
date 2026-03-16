Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # rubocop:disable Layout/LineLength
  scope "(:locale)", locale: /en|zh|hi|es|fr|ar|pt|ru|ja|de|jv|ko|vi|tr|ur|it|th|fa|pl|su|ha|my|uk|ms|tl|nl|ro|yo|ig|am|cs|el|hu|sv|he|sw|id|ne|si|ps|cy|ga|bg|hr|da|et|fi|is|lv|lt|mk|mt|nb|sk|sl|sq|sr|be|bs|ka|hy|az|ca|eu|gl|gd|lb/ do
    # rubocop:enable Layout/LineLength
    root "home#index"

    resources :chicken_shops, only: [:index, :show, :new, :create, :edit, :update] do
      resources :reviews, only: [:create, :edit, :update, :destroy]
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

    resources :badges, only: [:index]
    resource :leaderboard, only: [:show], controller: "leaderboard", action: "index"

    patch "locale", to: "locale#update", as: :update_locale

    get "privacy", to: "pages#privacy_policy", as: :privacy_policy
    get "terms", to: "pages#terms", as: :terms
    get "cookies", to: "pages#cookie_policy", as: :cookie_policy
  end

  get "api/shops", to: "api/shops#index"

  namespace :admin do
    root "dashboard#index"
    resources :users, only: [:index, :show] do
      member do
        patch :ban
        patch :unban
      end
    end
    resources :shops, only: [:index, :show, :edit, :update, :destroy]
    resources :reviews, only: [:index, :show, :destroy]
    resources :audit_logs, only: [:index]
  end

  # Fallback for sign-out via GET (when JS/Turbo is unavailable)
  get "users/sign_out", to: redirect("/")

  get "up" => "rails/health#show", :as => :rails_health_check
end
