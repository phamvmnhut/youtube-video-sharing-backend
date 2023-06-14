Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # action cable server
  mount ActionCable.server => "/cable"

  # Defines the root path route ("/")
  # root "articles#index"
  resources :registrations, only: [:create, :destroy]
  resources :sessions, only: [ :create, :destroy ]
  resources :shareds, only: [ :index, :create, :show, :destroy ]
  resources :users, only: [ :show ]
  resources :likes, only: [ :show, :create, :update, :destroy ]
  get '/likes_by_shared/:shared_id', to: 'likes#show_by_shared'
end
