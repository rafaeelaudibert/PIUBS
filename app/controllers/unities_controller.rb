# frozen_string_literal: true

class UnitiesController < ApplicationController
  before_action :set_unity, only: %i[show destroy]
  before_action :authenticate_user!
  before_action :filter_role
  include ApplicationHelper

  # GET /unities
  def index
    (@filterrific = initialize_filterrific(
      Unity,
      params[:filterrific],
      select_options: { # em breve
      },
      persistence_id: false
    )) || return
    @unities = @filterrific.find.joins(:city).order('cities.name', 'name').page(params[:page])
  end

  # GET /unities/1
  def show
    @contract = City.find(@unity.city_id).contract
  end

  # GET /unities/new
  def new
    @unity = Unity.new
    @city = City.find(params[:city]) if params[:city]
  end

  # POST /unities
  def create
    @unity = Unity.new(unity_params)
    if @unity.save
      redirect_to new_user_invitation_path(city_id: @unity.city_id,
                                           unity_id: @unity.id,
                                           role: 'ubs_admin'),
                  notice: 'Unity successfully created. Please add its responsible'
    else
      render :new
    end
  end

  # DELETE /unities/1
  # DELETE /unities/1.json
  def destroy
    @unity.destroy
    redirect_to unities_url, notice: 'Unity was successfully destroyed.'
  end

  # GET /cities/:cnes/users
  def users
    respond_to do |format|
      format.js { render json: User.where(cnes: params[:cnes]).order('id ASC') }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_unity
    @unity = Unity.find(params[:cnes])
  end

  # Never trust parameters from internet, only allow the white list through.
  def unity_params
    params.require(:unity).permit(:cnes, :name, :city_id)
  end

  def filter_role
    action = params[:action]
    if %w[new create destroy show].include? action
      redirect_to denied_path unless admin?
    elsif %w[index show].include? action
      redirect_to denied_path unless admin? || support_user?
    end
  end
end
