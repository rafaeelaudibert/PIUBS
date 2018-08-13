Rails.application.routes.draw do
  root to: 'visitors#index'

  resources :contracts
  get 'contracts/:id/download', to: 'contracts#download', as: 'download_contract'
  get 'cities/states/:id', to: 'cities#states'
  resources :companies, param: :sei
  resources :unities, param: :cnes
  resources :cities
  resources :states
  devise_for :users, controllers: { registrations: 'registrations' }
  resources :users
  get '404', to: 'application#page_not_found', as: 'not_found'
  get '422', to: 'application#acess_denied', as: 'denied'
end
