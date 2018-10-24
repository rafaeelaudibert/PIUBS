# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'welcome#index'

  scope '/apoioaempresas' do
    # /apoioaempresas
    get '/', to: 'calls#index' # Apoio a Empresas root


    # /apoioaempresas/attachments
    resources :attachments do
      collection do
        get ':id/download', to: 'attachments#download', as: 'download'
      end
    end

    # /apoioaempresas/answers
    get 'faq', to: 'answers#faq', as: 'faq'
    resources :answers do
      collection do
        get 'query/:search', to: 'answers#search'
        get 'attachments/:id', to: 'answers#attachments'
      end
    end

    # /apoioaempresas/replies
    resources :replies do
      collection do
        get 'attachments/:id', to: 'replies#attachments'
      end
    end

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

    # /apoioaempresas/contracts
    resources :contracts do
      collection do
        get '/:id/download', to: 'contracts#download', as: 'download'
      end
    end

    # /apoioaempresas/companies
    resources :companies, param: :sei do
      collection do
        get ':id/states', to: 'companies#states',
                          as: 'company_states'
        get ':id/users', to: 'companies#users',
                         as: 'company_users'
        get ':id/cities/:state_id', to: 'companies#cities',
                                    as: 'company_cities'
        get ':id/unities/:city_id', to: 'companies#unities',
                                    as: 'company_unities'
      end
    end

    # /apoioaempresas/unities
    resources :unities, param: :cnes

    # /apoioaempresas/cities
    resources :cities do
      collection do
        get 'states/:id', to: 'cities#states', as: 'states'
        get 'unities/:id', to: 'cities#unities', as: 'unities'
      end
    end

    # /apoioaempresas/states
    resources :states
  end

  scope '/controversias' do
    resources :controversies
  end

  # /apoioaempresas/users
  devise_for :users, controllers: { invitations: 'users/invitations',
                                    registrations: 'users/registrations' }
  resources :users

  # Errors
  get '404', to: 'application#page_not_found', as: 'not_found'
  get '422', to: 'application#acess_denied', as: 'denied'
end
