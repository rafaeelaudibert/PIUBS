class CitiesController < ApplicationController
  before_action :set_city, only: %i[show edit update destroy]
  include ApplicationHelper

  # GET /cities
  # GET /cities.json
  def index
    @cities = City.paginate(page: params[:page], per_page: 25)
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
      redirect_to @city, notice: 'City was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /cities/1
  def update
    if @city.update(city_params)
      redirect_to @city, notice: 'City was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /cities/1
  def destroy
    @city.destroy
    redirect_to cities_url, notice: 'City was successfully destroyed.'
  end

  # GET /cities/states
  def states
    respond_to do |format|
      format.js { render json: City.where('state_id = ?', params[:id]).order('id ASC') }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_city
    @city = City.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def city_params
    params.require(:city).permit(:name, :state_id)
  end
end
