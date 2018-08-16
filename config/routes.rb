Rails.application.routes.draw do
  resources :attachments
  get 'attachments/:id/download', to: 'attachments#download', as: 'download_attachment'

  get 'answers/query/:search', to: 'answers#search', as: 'answers_search'
  resources :answers
  resources :replies
  resources :calls

  get 'categories/all', to: 'categories#all', as: 'all_categories'
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
