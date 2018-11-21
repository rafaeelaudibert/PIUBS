# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show destroy]
  before_action :authenticate_user!
  before_action :filter_role
  include ApplicationHelper

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
    @company = Company.find(params[:sei])
    respond_to do |format|
      format.js do
        render json: State.where(id: @company
                                       .contracts
                                       .map { |c| c.city.state_id }
                                       .sort.uniq!)
      end
    end
  end

  # GET /companies/1/users
  def users
    respond_to do |format|
      format.js { render json: User.where(sei: params[:sei]).order('name ASC') }
    end
  end

  # GET /companies/1/cities/1
  def cities
    cities = retrieve_cities_for_company

    respond_to do |format|
      format.js do
        render json: cities
      end
    end
  end

  # GET /companies/1/unities/1
  def unities
    respond_to do |format|
      format.js do
        render json: City.find(params[:city_id]).unities
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:sei])
  end

  # Never trust parameters from internet, only allow the white list through.
  def company_params
    params.require(:company).permit(:sei)
  end

  def retrieve_cities_for_company
    if params[:id] == '0'
      City.where(state_id: params[:state_id])
    else
      City.where(id: Company.find(params[:id]).contracts.map(&:city_id),
                 state_id: params[:state_id])
    end.order('name')
  end

  def filter_role
    action = params[:action]
    if %w[index new create destroy].include? action
      redirect_to denied_path unless admin?
    elsif %w[states users cities unities].include? action
      redirect_to denied_path unless can_see_company_api?
    elsif action == 'show'
      redirect_if_cant_show
    end
  end

  def redirect_if_cant_show
    redirect_to denied_path unless sei_company_admin_or_admin?
  end

  def can_see_company_api?
    admin? || support_user? || params[:id].to_i == current_user.sei
  end

  def sei_company_admin_or_admin?
    (current_user.company_admin? && @company.sei == current_user.sei) || admin?
  end
end
