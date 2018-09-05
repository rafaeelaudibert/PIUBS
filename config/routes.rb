Rails.application.routes.draw do
  root to: 'visitors#index'

  resources :attachments
  get 'attachments/:id/download', to: 'attachments#download', as: 'download_attachment'

  get 'faq', to: 'answers#faq', as: 'faq'
  get 'answers/query/:search', to: 'answers#search', as: 'answers_search'
  get 'answers/attachments/:id', to: 'answers#attachments', as: 'answers_attachments'
  resources :answers

  get 'replies/attachments/:id', to: 'replies#attachments', as: 'replies_attachments'
  resources :replies

  resources :calls

  get 'categories/all', to: 'categories#all', as: 'all_categories'
  resources :categories

  resources :contracts
  get 'contracts/:id/download', to: 'contracts#download', as: 'download_contract'
  resources :contracts

  get 'companies/:id/cities/:state_id', to: 'companies#getCities', as: 'company_cities_path'
  get 'companies/:id/unities/:city_id', to: 'companies#getUnities', as: 'company_unities_path'
  resources :companies, param: :sei
  resources :unities, param: :cnes

  get 'cities/states/:id', to: 'cities#states'
  resources :cities
  resources :states

  devise_for :users, controllers: { invitations: 'users/invitations', registrations: 'registrations' }
  root to: 'visitors#index'
  get 'novo_usuario_nivel', to: 'users#pre_new_user_invitation', as: 'new_user_level'
  post 'novo_usuario_nivel_selecionado', to: 'users#get_invitation_role', as: 'new_user_level_selected'

  resources :users
  get '404', to: 'application#page_not_found', as: 'not_found'
  get '422', to: 'application#acess_denied', as: 'denied'
end
