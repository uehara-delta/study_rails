Rails.application.routes.draw do
  resources :books
  resources :users
  get 'admin' => 'admin/books#index'
  get 'admin.:id' => 'admin/books#show'
  get 'admin/new' => 'admin/books#new'
  post 'admin' => 'admin/books#create'
end
