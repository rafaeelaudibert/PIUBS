# frozen_string_literal: true

##
# This is the controller for the Company model
#
# It is responsible for handling the views for any Company
class CompaniesController < ApplicationController
  include ApplicationHelper

  # Hooks Configuration
  before_action :authenticate_user!
  before_action :set_company, only: %i[show destroy]

  # CanCanCan Configuration
  load_and_authorize_resource
  skip_authorize_resource only: %i[show states users cities unities]

  ####
  # :section: View methods
  # Method related to generating views
  ##

  # Configures the <tt>index</tt> page for the Company model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/companies</tt>
  # [GET] <tt>/companies.json</tt>
  def index
    (@filterrific = initialize_filterrific(
      Company,
      params[:filterrific],
      persistence_id: false
    )) || return
    @companies = filterrific_query
  end

  # Configures the <tt>show</tt> page for the Company model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/companies/:id</tt>
  # [GET] <tt>/companies/:id.json</tt>
  def show
    authorize! :show, @company

    @contracts = @company.contracts
                         .paginate(page: params[:page], per_page: 25)
    @users = @company.users
  end

  # Configures the <tt>new</tt> page for the Company model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/companies/new</tt>
  def new
    @company = Company.new
  end

  # Configures the <tt>POST</tt> request to create a new Company
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/companies</tt>
  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to new_user_invitation_path(sei: @company.sei, role: 'company_admin'),
                  notice: 'Empresa criada com sucesso. Por favor adicione o administrador dela.'
    else
      render :new
    end
  end

  # Configures the <tt>DELETE</tt> request to delete a Company
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/companies/:id</tt>
  def destroy
    @company.destroy
    redirect_to companies_url, notice: 'Empresa apagada com sucesso.'
  rescue StandardError
    redirect_back fallback_location: companies_url,
                  alert: 'A empresa não pode ser apagada pois possui'\
                         ' atendimentos/usuários cadastrados'
  end

  # Configures the <tt>states</tt> request for the Company model
  # It returns all State instances which have City children
  # related to the Company through a Contract
  #
  # <b>OBS.:</b> This view only exist in a JSON format
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/companies/:id/states.json</tt>
  def states
    @company = Company.find(params[:sei])
    authorize! :make_api_calls, @company

    @states = @company.states
  end

  # Configures the <tt>users</tt> request for the Company model
  # It returns all User instances which are children of the
  # queried Company
  #
  # <b>OBS.:</b> This view only exist in a JSON format
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/companies/:id/users.json</tt>
  def users
    @company = Company.find(params[:sei])
    authorize! :make_api_calls, @company

    @users = @company.users
  end

  # Configures the <tt>cities</tt> request for the Company model
  # It returns all City instances which are related to
  # this Company through a Contract
  #
  # <b>OBS.:</b> This view only exist in a JSON format
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/companies/:id/states/:state_id/cities.json</tt>
  def cities
    @company = Company.find(params[:id])
    authorize! :make_api_calls, @company

    @state = State.find(params[:state_id])
    @cities = retrieve_cities_for_company
  end

  private

  ####
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file
  ##

  # Configures the Company instance when called by
  # the <tt>:before_action</tt> hook
  def set_company
    @company = Company.find(params[:sei])
  end

  ####
  # :section: Custom private methods
  ##

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def company_params
    params.require(:company).permit(:sei)
  end

  # Called by #cities, return the City instances which are
  # related to the current Company through a Contract and
  # belong to the State refernt to the
  # <tt>state_id</tt> parameter,with the exception that if
  # the <tt>id</tt> parameter is 0 it return all City instances
  # related to that State, not just those with a Contract
  def retrieve_cities_for_company
    if params[:id] == '0'
      @state.cities
    else
      @company.cities_from_state params[:state_id]
    end
  end

  ####
  # :section: CanCanCan methods
  # Methods which are related to the CanCanCan gem
  ##

  # CanCanCan Method
  #
  # Default CanCanCan Method, declaring the CompanyAbility
  def current_ability
    @current_ability ||= CompanyAbility.new(current_user)
  end
end
