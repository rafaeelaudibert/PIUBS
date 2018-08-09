Rails.application.routes.draw do
  resources :categories
  resources :contracts
  get 'contracts/:id/download', to: 'contracts#download', as: 'download_contract'

  resources :companies, param: :sei
  resources :unities, param: :cnes
  resources :cities
  resources :states
  root to: 'visitors#index'
  devise_for :users, controllers: { registrations: 'registrations' }
  resources :users
  get '404', to: 'application#page_not_found', as: 'not_found'
  get '422', to: 'application#acess_denied', as: 'denied'
end
