# frozen_string_literal: true

class CallsController < ApplicationController
  before_action :set_call, only: %i[show edit update destroy]
  before_action :set_company, only: %i[create new]
  before_action :filter_role
  include ApplicationHelper

  # GET /calls
  # GET /calls.json
  def index
    if current_user.try(:call_center_user?)
      @calls = Call.where(support_user: [current_user.id, nil]).order(created_at: :desc).paginate(page: params[:page], per_page: 10)
    elsif current_user.try(:call_center_admin?)
      children = [nil]
      User.where(invited_by_id: current_user.id).each do |user|
        children << user.id
      end
      @calls = Call.where(support_user: children).order(created_at: :desc).paginate(page: params[:page], per_page: 10)
    elsif current_user.try(:admin?)
      @calls = Call.order(created_at: :desc).paginate(page: params[:page], per_page: 10)
    elsif current_user.try(:company_admin?)
      @calls = Call.where(sei: current_user.sei).order(created_at: :desc).paginate(page: params[:page], per_page: 10)
    elsif current_user.try(:company_user?)
      @calls = Call.where(user_id: current_user.id).order(created_at: :desc).paginate(page: params[:page], per_page: 10)
    else
      @calls = []
    end
  end

  # GET /calls/1
  def show
    @answer = Answer.new
    @reply = Reply.new
    @categories = Category.all
    @my_call = @call.support_user == current_user.id
    @user = User.find(@call.support_user) if @call.support_user
  end

  # GET /calls/new
  def new
    @call = Call.new
  end

  # GET /calls/1/edit
  def edit; end

  # POST /calls
  def create
    call_parameters = call_params
    files = call_parameters.delete(:file) if call_parameters[:file]
    @call = Call.new(call_parameters)
    # status, severity, protocol, company_id
    @call.protocol = Time.now.strftime('%Y%m%d%H%M%S%L').to_i
    @call.id = @call.protocol
    @call.user_id ||= current_user.id
    @call.sei ||= current_user.sei
    @call.open!               # Call is open by default
    @call.severity = 'normal' # Call has a normal severity by default

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

  # POST calls/link_call_support_user
  def link_call_support_user
    @call = Call.find(params[:call_options_id])
    if @call.support_user
      redirect_back(fallback_location: root_path, alert: 'Você não pode pegar um atendimento de outro usuário do suporte')
    else
      @call.support_user = current_user.id
      if @call.save
        redirect_back(fallback_location: root_path, notice: 'Agora esse atendimento é seu')
      else
        redirect_back(fallback_location: root_path, notice: 'Ocorreu um erro ao tentar pegar o atendimento')
      end
    end
  end

  # POST calls/unlink_call_support_user
  def unlink_call_support_user
    @call = Call.find(params[:call_options_id])
    if @call.support_user == current_user.id
      @call.support_user = ''
      if @call.save
        redirect_back(fallback_location: root_path, notice: 'Atendimento liberado')
      else
        redirect_back(fallback_location: root_path, notice: 'Ocorreu um erro ao tentar liberar o atendimento')
      end
    else
      redirect_back(fallback_location: root_path, alert: 'Esse atendimento pertence a outro usuário do suporte')
    end
  end

  # POST /calls/reopen_call
  def reopen_call
    @call = Call.find(params[:call])
    @call.reopened!

    if @call.save

      # Retira a última answer caso ela não esteja no FAQ, e exclui seus attachment_links
      if @call.answer_id && @call.answer.faq == false
        @answer = Answer.find(@call.answer_id)
        @answer.attachment_links.each(&:destroy)

        @call.answer_id = nil # Retira o answer_id
        raise 'We could not remove the call answer_id properly, when trying to reopen it. Please check it' unless @call.save

        @answer.destroy # Destroi a resposta final anterior
      end

      redirect_back(fallback_location: root_path, notice: 'Atendimento reaberto')
    else
      redirect_back(fallback_location: root_path, notice: 'Ocorreu um erro ao tentar reabrir o atendimento')
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_call
    @call = Call.find(params[:id])
  end

  def set_company
    @company = Company.find(current_user.sei) if current_user.sei
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def call_params
    params.require(:call).permit(:sei, :user_id, :title, :description, :finished_at, :version, :access_profile, :feature_detail, :answer_summary, :severity, :protocol, :city_id, :category_id, :state_id, :company_id, :cnes, file: [])
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

  def filter_role
    action = params[:action]
    if %w[edit update].include? action
      redirect_to denied_path unless is_admin?
    elsif %w[new create destroy].include? action
      redirect_to denied_path unless is_admin? || is_support_user? || is_company_user?
    elsif action == 'show'
      redirect_to denied_path unless (current_user.try(:company_admin?) && @call.sei == current_user.sei) || ((current_user.try(:company_user?) && @call.user_id == current_user.id)) || is_support_user? || is_admin?
    end
  end
end
