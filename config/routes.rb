# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  root to: 'welcome#index'

  # /users
  devise_for :users, controllers: { invitations: 'users/invitations',
                                    registrations: 'users/registrations' }
  resources :users do
    collection do
      get :autocomplete_user_company, to: 'users#autocomplete_company_users',
                                      as: 'autocomplete_company'
      get :autocomplete_user_city, to: 'users#autocomplete_city_users',
                                   as: 'autocomplete_city'
      get :autocomplete_user_unity, to: 'users#autocomplete_unity_users',
                                    as: 'autocomplete_unity'
      get :autocomplete_user_support, to: 'users#autocomplete_support_users',
                                      as: 'autocomplete_support'
    end
  end

  # Errors
  get '404', to: 'application#page_not_found', as: 'not_found'
  get '422', to: 'application#acess_denied', as: 'denied'

  # /attachments
  resources :attachments, only: %i[index create destroy] do
    collection do
      get ':id/download', to: 'attachments#download', as: 'download'
    end
  end

  # /answers
  resources :answers do
    collection do
      get 'query_call/:search', to: 'answers#search_call'
      get 'query_controversy/:search', to: 'answers#search_controversy'
      get 'attachments/:id', to: 'answers#attachments'
      get 'new/:source', to: 'answers#new'
    end
  end

  # /replies
  resources :replies, only: %i[create index show] do
    collection do
      get 'attachments/:id', to: 'replies#attachments'
    end
  end

  # /companies
  resources :companies, param: :sei, except: %i[edit update] do
    collection do
      get ':sei/states', to: 'companies#states',
                         as: 'company_states'
      get ':sei/users', to: 'companies#users',
                        as: 'company_users'
      get ':id/cities/:state_id', to: 'companies#cities',
                                  as: 'company_cities'
      get ':id/unities/:city_id', to: 'companies#unities',
                                  as: 'company_unities'
    end
  end

  # /unities
  resources :unities, param: :cnes, except: %i[edit update] do
    collection do
      get ':cnes/users', to: 'unities#users',
                         as: 'unity_users'
    end
  end

  # /contracts
  resources :contracts, except: %i[show edit update] do
    collection do
      get '/:id/download', to: 'contracts#download', as: 'download'
    end
  end

  # /cities
  resources :cities do
    collection do
      get 'states/:id', to: 'cities#states', as: 'city_states'
      get 'unities/:id', to: 'cities#unities', as: 'city_unities'
      get ':id/users', to: 'cities#users', as: 'city_users'
    end
  end

  # /states
  resources :states

  # /categories
  resources :categories do
    collection do
      get 'all'
      get 'category_select/:source', to: 'categories#category_select'
    end
  end

  scope '/apoioaempresas' do
    # /apoioaempresas
    get '/', to: 'calls#index', as: 'apoio_root' # Apoio a Empresas root

    # /apoioaempresas/faq
    get 'faq', to: 'answers#faq', as: 'faq'

    # /apoioaempresas/calls
    resources :calls do
      collection do
        post 'link_call_support_user'
        post 'unlink_call_support_user'
        post 'reopen_call'
      end
    end
  end

  scope '/controversias' do
    # /controversias
    get '/', to: 'controversies#index', as: 'controversias_root' # Controversias root

    # /controversias/faq
    get 'faq', to: 'answers#faq_controversy', as: 'faq_controversy'

    resources :controversies do
      collection do
        post 'link_controversy', to: 'controversies#link_controversy',
                                 as: 'link'
        post 'unlink_controversy', to: 'controversies#unlink_controversy',
                                   as: 'unlink'
        post ':id/company_user/:user_id', to: 'controversies#company_user',
                                          as: 'company_user'
        post ':id/city_user/:user_id', to: 'controversies#city_user',
                                       as: 'city_user'
        post ':id/unity_user/:user_id', to: 'controversies#unity_user',
                                        as: 'unity_user'
        post ':id/support_user/:user_id', to: 'controversies#support_user',
                                          as: 'support_user'
      end
    end

    resources :feedbacks
  end
end
