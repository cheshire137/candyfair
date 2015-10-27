Rails.application.routes.draw do
  devise_for :users

  resources :candies, only: [:index]

  root 'home#index'
end
