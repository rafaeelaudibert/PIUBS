class UnitiesController < ApplicationController
  before_action :set_unity, only: %i[show edit update destroy]

  # GET /unities
  def index
    @unities = Unity.paginate(page: params[:page], per_page: 25)
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

  # GET /unities/1/edit
  def edit; end

  # POST /unities
  def create
    @unity = Unity.new(unity_params)
    if @unity.save
      redirect_to @unity, notice: 'Unity was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /unities/1
  def update
    if @unity.update(unity_params)
      redirect_to @unity, notice: 'Unity was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /unities/1
  # DELETE /unities/1.json
  def destroy
    @unity.destroy
    redirect_to unities_url, notice: 'Unity was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_unity
    @unity = Unity.find(params[:cnes])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def unity_params
    params.require(:unity).permit(:cnes, :name, :city_id)
  end
end
