Rails.application.routes.draw do
  devise_for :users

  resources :candies, only: [:index]

  resources :people, only: [] do
    resources :preferences, only: [:index]
  end

  root 'home#index'
end
