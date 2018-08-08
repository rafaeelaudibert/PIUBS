class UnitiesController < ApplicationController
  before_action :set_unity, only: [:show, :edit, :update, :destroy]

  # GET /unities
  # GET /unities.json
  def index
    @unities = Unity.paginate(:page => params[:page], :per_page => 25)
  end

  # GET /unities/1
  # GET /unities/1.json
  def show
  end

  # GET /unities/new
  def new
    @unity = Unity.new
  end

  # GET /unities/1/edit
  def edit
  end

  # POST /unities
  # POST /unities.json
  def create
    @unity = Unity.new(unity_params)

    respond_to do |format|
      begin
        if @unity.save
          format.html { redirect_to @unity, notice: 'Unity was successfully created.' }
          format.json { render :show, status: :created, location: @unity }
        else
          handleError format, :new, ''
        end
      rescue => e
        puts e
        handleError format, :new, 'This CNES already exists in the database'
      end
    end
  end

  # PATCH/PUT /unities/1
  # PATCH/PUT /unities/1.json
  def update
    respond_to do |format|
      begin
        if @unity.update(unity_params)
          format.html { redirect_to @unity, notice: 'Unity was successfully updated.' }
          format.json { render :show, status: :ok, location: @unity }
        else
          handleError format, :edit, ''
        end
      rescue
        handleError format, :edit, 'This CNES already exists in the database'
      end
    end
  end

  # DELETE /unities/1
  # DELETE /unities/1.json
  def destroy
    @unity.destroy
    respond_to do |format|
      format.html { redirect_to unities_url, notice: 'Unity was successfully destroyed.' }
      format.json { head :no_content }
    end
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

    # Handle repeated values errors
    def handleError(format, method, message)
      @unity.errors.add(:cnes, :blank, message: message) unless message == ''
      format.html { render method }
      format.json { render json: @unity.errors, status: :unprocessable_entity }
    end
end
