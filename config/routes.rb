Rails.application.routes.draw do

  namespace :admin do
    resources :users, only: [:index, :show] do
      post '/prohibition', to: 'users#update'
      delete '/prohibition', to: 'users#destroy'
    end
  end

  get 'weekly_ranking', to: 'weekly_ranking#index'
  get 'all_time_ranking', to: 'all_time_ranking#index'

  resources :posts do
    resources :likes, only: [:create, :destroy]
    resources :comments, only: [:create]
  end

  devise_for :users, :controllers => {
    :registrations => 'users/registrations',
    :sessions => 'users/sessions'
  }

  devise_scope :user do
    get 'sign_in', :to => 'users/sessions#new'
    get 'sign_out', :to => 'users/sessions#destroy'
    post 'users/guest_sign_in', to: 'users/sessions#new_guest'
  end


  resources :users do
    member do
      get 'profile/show', to: 'users/profile#show'
      get 'profile/edit', to: 'users/profile#edit'
      patch 'profile/update', to: 'users/profile#update'
    end

    member do
      get :followings, :follower
    end
  end

  resources :follow_relationships, only: [:create, :destroy]

  root to: 'home#index'
end
