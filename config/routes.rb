# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  root to: 'welcome#index'

  # /users
  devise_for :users, controllers: { invitations: 'users/invitations',
                                    registrations: 'users/registrations' }
  resources :users do
    collection do
      get :autocomplete_company_users, to: 'users#autocomplete_company_users',
                                       as: 'autocomplete_company'
      get :autocomplete_city_users, to: 'users#autocomplete_city_users',
                                    as: 'autocomplete_city'
      get :autocomplete_unity_users, to: 'users#autocomplete_unity_users',
                                     as: 'autocomplete_unity'
      get :autocomplete_support_users, to: 'users#autocomplete_support_users',
                                       as: 'autocomplete_support'
      post ':id/update_system', to: 'users#update_system', as: 'update_system'
      post ':id/update_role', to: 'users#update_role', as: 'update_role'
    end
  end

  # Errors
  get '404', to: 'application#page_not_found', as: 'not_found'
  get '422', to: 'application#acess_denied', as: 'denied'
  get '500', to: 'application#internal_error', as: 'internal_error'

  # /attachments
  resources :attachments, only: %i[index create destroy] do
    collection do
      get ':id/download', to: 'attachments#download', as: 'download'
    end
  end

  # /answers
  resources :answers, except: :destroy do
    collection do
      get ':id/attachments', to: 'answers#attachments'
      get 'query_call/:search', to: 'answers#search_call'
      get 'query_controversy/:search', to: 'answers#search_controversy'
      get 'new/:source', to: 'answers#new'
    end
  end

  # /replies
  resources :replies, only: %i[create index show] do
    collection do
      get ':id/attachments', to: 'replies#attachments'
    end
  end

  # /companies
  resources :companies, param: :sei, except: %i[edit update] do
    collection do
      get ':sei/states', to: 'companies#states',
                         as: 'company_states'
      get ':sei/users', to: 'companies#users',
                        as: 'company_users'
      get ':id/states/:state_id/cities', to: 'companies#cities',
                                         as: 'company_cities'
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
  resources :cities, except: %i[edit update destroy] do
    collection do
      get ':id/unities', to: 'cities#unities', as: 'city_unities'
      get ':id/users', to: 'cities#users', as: 'city_users'
    end
  end

  # /states
  resources :states, except: %i[edit update destroy] do
    collection do
      get ':id/cities', to: 'states#cities', as: 'state_cities'
    end
  end

  # /categories
  resources :categories, except: %i[edit update show] do
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
    resources :calls, except: %i[edit update destroy] do
      collection do
        post ':id/link_call_support_user', to: 'calls#link_call_support_user',
                                           as: 'link_call_support_user'
        post ':id/unlink_call_support_user', to: 'calls#unlink_call_support_user'
        post ':id/reopen_call', to: 'calls#reopen_call', as: 'reopen_call'
      end
    end
  end

  scope '/controversias' do
    # /controversias
    get '/', to: 'controversies#index', as: 'controversias_root' # Controversias root

    # /controversias/faq
    get 'faq', to: 'answers#faq_controversy', as: 'faq_controversy'

    resources :controversies, except: %i[edit update destroy] do
      collection do
        post ':id/link_controversy/:user_id', to: 'controversies#link_controversy',
                                              as: 'link'
        post ':id/unlink_controversy/:user_id', to: 'controversies#unlink_controversy',
                                                as: 'unlink'
        post ':id/link_company_user/:user_id', to: 'controversies#link_company_user',
                                               as: 'company_user'
        post ':id/link_city_user/:user_id', to: 'controversies#link_city_user',
                                            as: 'city_user'
        post ':id/link_unity_user/:user_id', to: 'controversies#link_unity_user',
                                             as: 'unity_user'
        post ':id/link_support_user/:user_id', to: 'controversies#link_support_user',
                                               as: 'support_user'
      end
    end

    resources :feedbacks, only: %i[create index show]
  end
end
