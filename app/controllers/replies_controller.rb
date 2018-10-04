# frozen_string_literal: true

class RepliesController < ApplicationController
  before_action :set_reply, only: %i[show edit update destroy]
  before_action :filter_role
  include ApplicationHelper

  # GET /replies
  def index
    @replies = Reply.order('created_at DESC').paginate(page: params[:page], per_page: 25)
  end

  # GET /replies/1
  def show; end

  # GET /replies/new
  def new
    @reply = Reply.new
  end

  # GET /replies/1/edit
  def edit; end

  # POST /replies
  def create
    rep_params = reply_params
    files = rep_params.delete(:file) if rep_params[:file]
    faq_attachments_ids = rep_params.delete(:faq_attachments).split(',') if rep_params[:faq_attachments]
    @reply = Reply.new(rep_params)
    @reply.user_id = current_user.id
    @reply.status = @reply.call.status || 'Sem Status'
    @reply.category = is_support_user || current_user.try(:admin?) ? 'support' : 'reply'

    if @reply.save
      # CREATE an attachment
      if files
        parsed_params = attachment_params files
        parsed_params[:filename].each_with_index do |_filename, _index|
          @attachment = Attachment.new(eachAttachment(parsed_params, _index))
          raise 'Não consegui anexar o arquivo. Por favor tente mais tarde' unless @attachment.save

          @link = AttachmentLink.new(attachment_id: @attachment.id, reply_id: @reply.id, source: 'reply')
          raise 'Não consegui criar o link entre arquivo e a resposta. Por favor tente mais tarde' unless @link.save
        end
      end

      # "IMPORT" attachments from the faq answer to this reply
      faq_attachments_ids&.each do |_id|
        @link = AttachmentLink.new(attachment_id: _id, reply_id: @reply.id, source: 'reply')
        raise 'Não consegui criar o link entre arquivo que veio do FAQ e a resposta. Por favor tente mais tarde' unless @link.save
      end

      ReplyMailer.notify(@reply, current_user).deliver_later
      redirect_to call_path(@reply.protocol), notice: 'Reply was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /replies/1
  def update
    if @reply.update(reply_params)
      redirect_to @reply, notice: 'Reply was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /replies/1
  def destroy
    @reply.destroy
    redirect_to replies_url, notice: 'Reply was successfully destroyed.'
  end

  # GET /replies/attachments/:id
  def attachments
    respond_to do |format|
      format.js { render json: Reply.find(params[:id]).attachments.map { |_attachment| { filename: _attachment.filename, id: _attachment.id } } }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_reply
    @reply = Reply.find(params[:id])
  end

  def is_company_user
    current_user.try(:company_user?) || current_user.try(:company_admin?)
  end

  def is_support_user
    current_user.try(:call_center_user?) || current_user.try(:call_center_admin?)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def reply_params
    params.require(:reply).permit(:faq_attachments, :protocol, :description, :user_id, :faq, file: [])
  end

  def filter_role
    action = params[:action]
    if %w[index destroy edit update show].include? action
      redirect_to denied_path unless is_admin?
    elsif %w[attachments].include? action
      redirect_to denied_path unless is_admin? || is_support_user
    end
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
