# frozen_string_literal: true

class CitiesController < ApplicationController
  before_action :authenticate_user!
  include ApplicationHelper

  load_and_authorize_resource
  skip_authorize_resource only: %i[users unities]

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

  # GET /cities/:id/unities
  def unities
    @city = City.find(params[:id])
    authorize! :make_api_calls, @city

    render json: @city.unities.order('name ASC')
  end

  # GET /cities/:id/users
  def users
    @city = City.find(params[:id])
    authorize! :make_api_calls, @city

    render json: User.where(city: @city, cnes: nil).order('id ASC')
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

  def current_ability
    @current_ability ||= CityAbility.new(current_user)
  end
end
