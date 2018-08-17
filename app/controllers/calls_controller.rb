class CallsController < ApplicationController
  before_action :set_call, only: %i[show edit update destroy]

  # GET /calls
  # GET /calls.json
  def index
    @calls = Call.all
  end

  # GET /calls/1
  # GET /calls/1.json
  def show
    @reply = Reply.new
    @categories = Category.all
  end

  # GET /calls/new
  def new
    @call = Call.new
  end

  # GET /calls/1/edit
  def edit; end

  # POST /calls
  # POST /calls.json
  def create
    @call = Call.new(call_params)
    # status, severity, protocol, company_id
    user = current_user
    @call.sei = user.sei
    @call.status = 0
    @call.protocol = get_protocol
    @call.severity = 'Normal'
    @call.user_id = user.id
    @call.id = @call.protocol
    
    respond_to do |format|
      if @call.save
        format.html { redirect_to @call, notice: 'Call was successfully created.' }
        format.json { render :show, status: :created, location: @call }
      else
        format.html { render :new }
        format.json { render json: @call.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /calls/1
  # PATCH/PUT /calls/1.json
  def update
    respond_to do |format|
      if @call.update(call_params)
        format.html { redirect_to @call, notice: 'Call was successfully updated.' }
        format.json { render :show, status: :ok, location: @call }
      else
        format.html { render :edit }
        format.json { render json: @call.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /calls/1
  # DELETE /calls/1.json
  def destroy
    @call.destroy
    respond_to do |format|
      format.html { redirect_to calls_url, notice: 'Call was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_call
    @call = Call.find(params[:id])
  end

  def get_current_time
    Time.zone.now.strftime('%H%M%S')
  end

  def get_current_date
    Date.today.strftime('%d%m%Y')
  end

  def get_protocol
    user = format('%05d', current_user.id.to_i) # Leading zeros, allowing to have 99999 users
    time = get_current_time
    date = get_current_date
    protocol = "#{date}#{time}#{user}"
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def call_params
    params.require(:call).permit(:title, :description, :finished_at, :status, :version, :access_profile, :feature_detail, :answer_summary, :severity, :protocol, :city_id, :category_id, :state_id, :company_id)
  end
end
