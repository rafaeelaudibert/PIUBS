class CallsController < ApplicationController
  before_action :set_call, only: %i[show edit update destroy]
  include ApplicationHelper

  # GET /calls
  # GET /calls.json
  def index
    if current_user.try(:call_center_user?) || current_user.try(:call_center_admin?) || current_user.try(:admin?)
      @calls = Call.paginate(page: params[:page], per_page: 25)
    elsif current_user.try(:company_admin?)
      @calls = Call.where('sei = ?', current_user.sei).paginate(page: params[:page], per_page: 25)
    elsif current_user.try(:company_user?)
      @calls = Call.where('user_id = ?', current_user.id).paginate(page: params[:page], per_page: 25)
    else
      @calls = []
    end
  end

  # GET /calls/1
  def show
    @answer = Answer.new
    @reply = Reply.new
    @categories = Category.all
  end

  # GET /calls/new
  def new
    @call = Call.new
    @company = Company.find(params[:sei]) if params[:sei]
  end

  # GET /calls/1/edit
  def edit; end

  # POST /calls
  def create
    call_parameters = call_params
    files = call_parameters.delete(:file) if call_parameters[:file]
    @call = Call.new(call_parameters)
    # status, severity, protocol, company_id
    @call.status = 0
    @call.protocol = Time.now.strftime('%Y%m%d%H%M%S%L').to_i
    @call.severity = 'Normal'
    @call.id = @call.protocol
    @call.user_id ||= current_user.id
    @call.sei ||= current_user.sei

    if @call.save
      if files
        parsed_params = attachment_params files
        parsed_params[:filename].each_with_index do |_filename, _index|
          @attachment = Attachment.new(eachAttachment(parsed_params, _index))
          raise 'Não consegui anexar o arquivo. Por favor tente mais tarde' unless @attachment.save

          @link = AttachmentLink.new(attachment_id: @attachment.id, call_id: @call.id, source: 'call')
          raise 'Não consegui criar o link entre arquivo e o atendimento. Por favor tente mais tarde' unless @link.save
        end
      end

      CallMailer.notify(@call, @call.user).deliver
      redirect_to @call, notice: 'Call was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /calls/1
  def update
    if @call.update(call_params)
      redirect_to @call, notice: 'Call was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /calls/1
  # DELETE /calls/1.json
  def destroy
    @call.destroy
    redirect_to calls_url, notice: 'Call was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_call
    @call = Call.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def call_params
    params.require(:call).permit(:sei, :user_id, :title, :description, :finished_at, :status, :version, :access_profile, :feature_detail, :answer_summary, :severity, :protocol, :city_id, :category_id, :state_id, :company_id, :cnes, file: [])
  end

  ## ATTACHMENTS STUFF
  # Never trust parameters from the scary internet, only allow the white list through.
  def attachment_params(file)
    parameters = {}
    if file
      parameters[:filename] = []
      parameters[:content_type] = []
      parameters[:file_contents] = []
      file.each do |_file|
        parameters[:filename].append(File.basename(_file.original_filename))
        parameters[:content_type].append(_file.content_type)
        parameters[:file_contents].append(_file.read)
      end
    end
    parameters
  end

  def eachAttachment(_parsed_params, _index)
    new_params = {}
    new_params[:filename] = _parsed_params[:filename][_index]
    new_params[:content_type] = _parsed_params[:content_type][_index]
    new_params[:file_contents] = _parsed_params[:file_contents][_index]
    new_params
  end
end
