# frozen_string_literal: true

class CitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :filter_role
  before_action :set_city, only: %i[show edit update destroy]
  include ApplicationHelper

  # GET /cities
  # GET /cities.json
  def index
    (@filterrific = initialize_filterrific(
      City,
      params[:filterrific],
      select_options: options_for_filterrific,
      persistence_id: false
    )) || return
    @cities = @filterrific.find.joins(:state).order('states.name', 'cities.name')
                          .page(params[:page])
  end

  # GET /cities/1
  def show
    @city = City.find(params[:id])
    @ubs = @city.unity_ids.sort
    @contract = @city.contract
  end

  # GET /cities/new
  def new
    @city = City.new
    @state = State.find(params[:state]) if params[:state]
  end

  # POST /cities
  def create
    @city = City.new(city_params)
    if @city.save
      redirect_to new_user_invitation_path(city_id: @city.id,
                                           role: 'city_admin'),
                  notice: 'Cidade criada com sucesso. Por favor, adicione seu responsável'
    else
      render :new
    end
  end

  # GET /cities/states/:id
  def states
    respond_to do |format|
      format.js { render json: State.find(params[:id]).cities }
    end
  end

  # GET /cities/unities/:id
  def unities
    respond_to do |format|
      format.js { render json: City.find(params[:id]).unities.order('name ASC') }
    end
  end

  # GET /cities/:id/users
  def users
    respond_to do |format|
      format.js { render json: User.where(city_id: params[:id], cnes: nil).order('id ASC') }
    end
  end

  private

  def options_for_filterrific
    {
      with_state: State.all.map { |s| [s.name, s.id] },
      sorted_by_name: City.all.options_for_sorted_by_name
    }
  end

  # Never trust parameters from internet, only allow the white list through.
  def city_params
    params.require(:city).permit(:name, :state_id)
  end

  def filter_role
    action = params[:action]
    if %w[new create].include? action
      redirect_to denied_path unless admin?
    elsif %w[index show].include? action
      redirect_to denied_path unless admin? || support_user?
    end
  end
end
