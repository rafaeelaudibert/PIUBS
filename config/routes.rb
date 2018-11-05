# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  root to: 'welcome#index'

  # /users
  devise_for :users, controllers: { invitations: 'users/invitations',
                                    registrations: 'users/registrations' }
  resources :users

  # Errors
  get '404', to: 'application#page_not_found', as: 'not_found'
  get '422', to: 'application#acess_denied', as: 'denied'

  # /attachments
  resources :attachments do
    collection do
      get ':id/download', to: 'attachments#download', as: 'download'
    end
  end

  # /answers
  resources :answers do
    collection do
      get 'query/:search', to: 'answers#search'
      get 'attachments/:id', to: 'answers#attachments'
    end
  end

  # /replies
  resources :replies do
    collection do
      get 'attachments/:id', to: 'replies#attachments'
    end
  end

  # /companies
  resources :companies, param: :sei do
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
  resources :unities, param: :cnes do
    collection do
      get ':cnes/users', to: 'unities#users',
                         as: 'unity_users'
    end
  end

  # /contracts
  resources :contracts do
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

    # /apoioaempresas/categories
    resources :categories do
      collection do
        get 'all'
      end
    end
  end

  scope '/controversias' do
    # /controversias
    get '/', to: 'controversies#index', as: 'controversias_root' # Controversias root

    resources :controversies do
      collection do
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
  end
end
