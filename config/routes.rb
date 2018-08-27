Rails.application.routes.draw do
  root to: 'visitors#index'

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
  resources :contracts

  resources :companies, param: :sei
  resources :unities, param: :cnes

  get 'cities/states/:id', to: 'cities#states'
  resources :cities
  resources :states

  devise_for :users, :controllers => {:invitations => "users/invitations", :registrations => "registrations"}
  root to: 'visitors#index'
  get 'novo_usuario_nivel', to: 'users#pre_new_user_invitation', as: 'new_user_level'
  post 'novo_usuario_nivel_selecionado', to: 'users#get_invitation_role', as: 'new_user_level_selected'

  resources :users
  get '404', to: 'application#page_not_found', as: 'not_found'
  get '422', to: 'application#acess_denied', as: 'denied'
end
