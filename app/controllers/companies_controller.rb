# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show edit update destroy]
  before_action :filter_role
  include ApplicationHelper

  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.order('sei').paginate(page: params[:page], per_page: 25)
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @contracts = Contract.where('sei = ?', @company.sei).paginate(page: params[:page], per_page: 25)
    @users = User.where('sei = ?', @company.sei)
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit; end

  # POST /companies
  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to new_user_invitation_path(sei: @company.sei, role: 'company_admin'), notice: 'Company was successfully created. Please add its admin'
    else
      render :new
    end
  end

  # PATCH/PUT /companies/1
  def update
    if @company.update(company_params)
      redirect_to @company, notice: 'Company was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /companies/1
  def destroy
    begin
    @company.destroy
      redirect_to companies_url, notice: 'Company was successfully destroyed.'
    rescue
      redirect_back fallback_location: companies_url, alert: 'A empresa não pode ser apagada pois possui atendimentos/usuários cadastrados'
    end
  end

  # GET /companies/1/states
  def getStates
    @company = Company.find(params[:id])
    respond_to do |format|
      format.js { render json: State.where(id: @company.state_ids).order('id ASC') }
    end
  end

  # GET /companies/1/users
  def getUsers
    @company = Company.find(params[:id])
    respond_to do |format|
      format.js { render json: User.where(sei: @company.sei).order('id ASC') }
    end
  end

  # GET /companies/1/cities/1
  def getCities
    @company = Company.find(params[:id])
    respond_to do |format|
      format.js { render json: City.where(id: @company.city_ids, state_id: params[:state_id]).order('id ASC') }
    end
  end

  # GET /companies/1/unities/1
  def getUnities
    @company = Company.find(params[:id])
    respond_to do |format|
      format.js { render json: Unity.where(city_id: params[:city_id]).order('cnes ASC') }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:sei])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def company_params
    params.require(:company).permit(:sei)
  end

  def filter_role
    action = params[:action]
    if %w[index new create destroy edit update].include? action
      redirect_to denied_path unless is_admin?
    elsif %w[getStates getUsers getCities getUnities].include? action
      redirect_to denied_path unless is_admin? || is_support_user? || (is_company_user && params[:id].to_i == current_user.sei)
    elsif action == 'show'
      redirect_to denied_path unless current_user.try(:company_admin?) && @company.sei == current_user.sei || is_admin?
    end
  end
end
