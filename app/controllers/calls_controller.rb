# frozen_string_literal: true

class CallsController < ApplicationController
  before_action :set_call, only: %i[show edit update destroy]
  before_action :set_company, only: %i[create new]
  before_action :authenticate_user!
  before_action :filter_role
  include ApplicationHelper

  # GET /calls
  # GET /calls.json
  def index
    @contracts = Contract.where(sei: current_user.sei)
    (@filterrific = initialize_filterrific(Call, params[:filterrific],
                                           select_options: { sorted_by_creation: Call.options_for_sorted_by_creation,
                                                             with_status: Call.options_for_with_status,
                                                             with_state: State.all.map { |s| [s.name, s.id] },
                                                             with_city: Call.options_for_with_city,
                                                             with_ubs: Unity.where(city_id: @contracts.map(&:city_id)).map { |u| [u.name, u.cnes] },
                                                             with_company: Company.all.map(&:sei) },
                                           persistence_id: false)) || return
    if user_signed_in?
      filtered_calls
    else
      redirect_to new_user_session_path
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def filtered_calls
    if current_user.try(:call_center_user?)
      @calls = @filterrific.find.page(params[:page]).where(support_user: [current_user.id, nil])
    elsif current_user.try(:call_center_admin?)
      children = User.where(invited_by_id: current_user.id).map(&:id)
      @calls = @filterrific.find.page(params[:page]).where(support_user: [children, nil].flatten)
    elsif current_user.try(:company_admin?)
      @calls = @filterrific.find.page(params[:page]).where(sei: current_user.sei)
    elsif current_user.try(:company_user?)
      @calls = @filterrific.find.page(params[:page]).where(user_id: current_user.id)
    elsif current_user.try(:admin?)
      @calls = @filterrific.find.page(params[:page])
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
    files = call_parameters.delete(:files).split(',') if call_parameters[:files]
    @call = Call.new(call_parameters)
    # status, severity, protocol, company_id
    @call.protocol = Time.now.strftime('%Y%m%d%H%M%S%L').to_i
    @call.id = @call.protocol
    @call.user_id ||= current_user.id
    @call.sei ||= current_user.sei
    @call.open!               # Call is open by default
    @call.severity = 'normal' # Call has a normal severity by default

    if @call.save
      files.each do |file_uuid|
        @link = AttachmentLink.new(attachment_id: file_uuid,
                                   call_id: @call.id,
                                   source: 'call')
        unless @link.save
          raise 'Não consegui criar o link entre arquivo e o atendimento.'\
                ' Por favor tente mais tarde'
        end
      end

      CallMailer.notify(@call, @call.user).deliver_later
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
      redirect_back(fallback_location: root_path,
                    alert: 'Você não pode pegar um atendimento de outro usuário do suporte')
    else
      @call.support_user = current_user.id
      if @call.save
        redirect_back(fallback_location: root_path,
                      notice: 'Agora esse atendimento é seu')
      else
        redirect_back(fallback_location: root_path,
                      notice: 'Ocorreu um erro ao tentar pegar o atendimento')
      end
    end
  end

  # POST calls/unlink_call_support_user
  def unlink_call_support_user
    @call = Call.find(params[:call_options_id])
    if @call.support_user == current_user.id
      @call.support_user = ''
      if @call.save
        redirect_back(fallback_location: root_path,
                      notice: 'Atendimento liberado')
      else
        redirect_back(fallback_location: root_path,
                      notice: 'Ocorreu um erro ao tentar liberar o atendimento')
      end
    else
      redirect_back(fallback_location: root_path,
                    alert: 'Esse atendimento pertence a outro usuário do suporte')
    end
  end

  # POST /calls/reopen_call
  def reopen_call
    @call = Call.find(params[:call])
    @call.reopened!

    if @call.save

      # Retira a ultima answer caso ela nao esteja no FAQ,
      # e exclui seus attachment_links
      if @call.answer_id && @call.answer.faq == false
        @answer = Answer.find(@call.answer_id)
        @answer.attachment_links.each(&:destroy)

        @call.answer_id = nil # Retira o answer_id
        unless @call.save
          raise 'Não conseguimos remover a call_id corretamente, ao tentar reabri-la.'\
                ' Por favor, verifique'
        end

        @answer.destroy # Destroi a resposta final anterior
      end

      redirect_back(fallback_location: root_path,
                    notice: 'Atendimento reaberto')
    else
      redirect_back(fallback_location: root_path,
                    notice: 'Ocorreu um erro ao tentar reabrir o atendimento')
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

  # Never trust parameters from internet, only allow the white list through.
  def call_params
    params.require(:call).permit(:sei, :user_id, :title,
                                 :description, :finished_at, :version,
                                 :access_profile, :feature_detail,
                                 :answer_summary, :severity, :protocol,
                                 :city_id, :category_id, :state_id,
                                 :company_id, :cnes, :files)
  end

  def filter_role
    action = params[:action]
    if %w[edit update].include? action
      redirect_to denied_path unless admin?
    elsif %w[new create destroy].include? action
      redirect_to denied_path unless admin? || support_user? || company_user?
    elsif action == 'show'
      unless (current_user.try(:company_admin?) && @call.sei == current_user.sei) ||
             (current_user.try(:company_user?) && @call.user_id == current_user.id) ||
             support_user? ||
             admin?
        redirect_to denied_path
      end
    elsif action == 'index'
      redirect_to faq_path unless admin? || support_user? || company_user?
    end
  end
end
