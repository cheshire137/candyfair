Rails.application.routes.draw do
  devise_for :users

  resources :candies, only: [:index, :create, :show, :destroy] do
    collection do
      get :trends
    end
    member do
      get :wikipedia
    end
  end

  resources :people, only: [:index, :create, :show, :destroy] do
    resources :preferences, only: [:index, :create, :destroy]
  end

  root 'home#index'
end
