class ControversiesController < ApplicationController
  before_action :set_controversy, only: [:show, :edit, :update, :destroy]

  # GET /controversies
  # GET /controversies.json
  def index
    @controversies = Controversy.all
  end

  # GET /controversies/1
  # GET /controversies/1.json
  def show
  end

  # GET /controversies/new
  def new
    @controversy = Controversy.new
  end

  # GET /controversies/1/edit
  def edit
  end

  # POST /controversies
  # POST /controversies.json
  def create
    @controversy = Controversy.new(controversy_params)

    respond_to do |format|
      if @controversy.save
        format.html { redirect_to @controversy, notice: 'Controversy was successfully created.' }
        format.json { render :show, status: :created, location: @controversy }
      else
        format.html { render :new }
        format.json { render json: @controversy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /controversies/1
  # PATCH/PUT /controversies/1.json
  def update
    respond_to do |format|
      if @controversy.update(controversy_params)
        format.html { redirect_to @controversy, notice: 'Controversy was successfully updated.' }
        format.json { render :show, status: :ok, location: @controversy }
      else
        format.html { render :edit }
        format.json { render json: @controversy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /controversies/1
  # DELETE /controversies/1.json
  def destroy
    @controversy.destroy
    respond_to do |format|
      format.html { redirect_to controversies_url, notice: 'Controversy was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_controversy
      @controversy = Controversy.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def controversy_params
      params.require(:controversy).permit(:title, :description, :protocol, :closed_at, :sei, :contract_id, :city_id, :cnes, :company_user_id, :unity_user_id, :creator, :category, :complexity, :support_1_id, :support_2_id)
    end
end
