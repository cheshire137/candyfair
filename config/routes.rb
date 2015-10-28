Rails.application.routes.draw do
  devise_for :users

  resources :candies, only: [:index, :create, :show] do
    collection do
      post :add
      delete :destroy
    end
  end

  resources :people, only: [:index] do
    resources :preferences, only: [:index, :create, :destroy]
  end

  root 'home#index'
end
