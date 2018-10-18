# frozen_string_literal: true

class CitiesController < ApplicationController
  before_action :set_city, only: %i[show edit update destroy]
  before_action :authenticate_user!
  before_action :filter_role
  include ApplicationHelper

  # GET /cities
  # GET /cities.json
  def index
    (@filterrific = initialize_filterrific(
      City,
      params[:filterrific],
      select_options: { # em breve
      },
      persistence_id: false
    )) || return
    @cities = @filterrific.find.page(params[:page]).order('state_id, name')
  end

  # GET /cities/1
  def show
    @ubs = @city.unity_ids.sort
    @contract = @city.contract
  end

  # GET /cities/new
  def new
    @city = City.new
    @state = State.find(params[:state]) if params[:state]
  end

  # GET /cities/1/edit
  def edit; end

  # POST /cities
  def create
    @city = City.new(city_params)
    if @city.save
      redirect_to @city, notice: 'Cidade criada com sucesso.'
    else
      render :new
    end
  end

  # PATCH/PUT /cities/1
  def update
    if @city.update(city_params)
      redirect_to @city, notice: 'Cidade atualizada com sucesso.'
    else
      render :edit
    end
  end

  # DELETE /cities/1
  def destroy
    @city.destroy
    redirect_to cities_url, notice: 'Cidade apagada com sucesso.'
  end

  # GET /cities/states
  def states
    respond_to do |format|
      format.js { render json: City.where(state_id: params[:id]).order('id ASC') }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_city
    @city = City.find(params[:id])
  end

  # Never trust parameters from internet, only allow the white list through.
  def city_params
    params.require(:city).permit(:name, :state_id)
  end

  def filter_role
    action = params[:action]
    if %w[new create destroy edit update show].include? action
      redirect_to denied_path unless admin?
    elsif %w[index show states].include? action
      redirect_to denied_path unless admin? || support_user?
    end
  end
end
