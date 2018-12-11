# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, except: %i[index new create destroy]
  include ApplicationHelper

  load_and_authorize_resource
  skip_authorize_resource only: %i[show states users cities unities]

  # GET /companies
  # GET /companies.json
  def index
    (@filterrific = initialize_filterrific(
      Company,
      params[:filterrific],
      select_options: { # em breve
      },
      persistence_id: false
    )) || return
    @companies = @filterrific.find.order(:sei).page(params[:page])
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    authorize! :show, @company
    @contracts = Contract.where(sei: @company.sei)
                         .order('city_id')
                         .paginate(page: params[:page], per_page: 25)
    @users = User.where(sei: @company.sei)
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # POST /companies
  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to new_user_invitation_path(sei: @company.sei, role: 'company_admin'),
                  notice: 'Empresa criada com sucesso. Por favor adicione o administrador dela.'
    else
      render :new
    end
  end

  # DELETE /companies/1
  def destroy
    @company.destroy
    redirect_to companies_url, notice: 'Empresa apagada com sucesso.'
  rescue StandardError
    redirect_back fallback_location: companies_url,
                  alert: 'A empresa não pode ser apagada pois possui'\
                         ' atendimentos/usuários cadastrados'
  end

  # GET /companies/1/states
  def states
    authorize! :make_api_calls, @company

    render json: State.where(id: @company
                                   .contracts
                                   .map { |c| c.city.state_id }
                                   .sort.uniq!)
  end

  # GET /companies/1/users
  def users
    authorize! :make_api_calls, @company

    render json: User.where(company: @company).order('name ASC')
  end

  # GET /companies/1/cities/1
  def cities
    authorize! :make_api_calls, @company

    render json: retrieve_cities_for_company
  end

  # GET /companies/1/unities/1
  def unities
    authorize! :make_api_calls, @company

    render json: City.find(params[:city_id]).unities
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:sei])
  end

  def retrieve_cities_for_company
    if params[:sei] == '0'
      City.where(state_id: params[:state_id])
    else
      City.where(id: @company.contracts.map(&:city_id),
                 state_id: params[:state_id])
    end.order('name')
  end

  # Never trust parameters from internet, only allow the white list through.
  def company_params
    params.require(:company).permit(:sei)
  end

  def current_ability
    @current_ability ||= CompanyAbility.new(current_user)
  end
end
