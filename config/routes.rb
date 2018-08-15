Rails.application.routes.draw do
  resources :contracts
  resources :companies, param: :sei
  resources :unities, param: :cnes
  resources :cities
  resources :states
  root to: 'visitors#index'
  get 'novo_usuario_nivel',  :to => 'users#pre_new'
  post 'novo_usuario_nivel_selecionado',  :to => 'users#get_invitation_role'

  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users
  get '404', :to => 'application#page_not_found', as: 'not_found'
  get '422', :to => 'application#acess_denied', as: 'denied'
end
