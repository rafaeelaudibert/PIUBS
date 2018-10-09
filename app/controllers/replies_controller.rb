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
    files = rep_params.delete(:files).split(',') if rep_params[:files]

    # TODO: TO BE REPLACED IN THE NEXT COMMITS WITH FURTHER DROPZONE IMPLEMENTATION
    attach = rep_params[:faq_attachments]
    faq_attachments_ids = rep_params.delete(:faq_attachments).split(',') if attach
    ###

    @reply = Reply.new(rep_params)
    @reply.user_id = current_user.id
    @reply.status = @reply.call.status || 'Sem Status'
    @reply.category = support_user? || current_user.try(:admin?) ? 'support' : 'reply'

    if @reply.save
      if files
        files.each do |file_uuid|
          @link = AttachmentLink.new(attachment_id: file_uuid,
                                     reply_id: @reply.id, source: 'reply')

          raise 'Não consegui criar o link entre arquivo e a resposta.'\
                ' Por favor tente mais tarde' unless @link.save
        end
      end

      # "IMPORT" attachments from the faq answer to this reply
      faq_attachments_ids&.each do |id|
        @link = AttachmentLink.new(attachment_id: id, reply_id: @reply.id, source: 'reply')
        unless @link.save
          raise 'Não consegui criar o link entre arquivo que veio do FAQ e a resposta.'\
                ' Por favor tente mais tarde'
        end
      end

      ReplyMailer.notify(@reply, current_user).deliver_later
      redirect_to call_path(@reply.protocol),
                  notice: 'Reply was successfully created.'
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
      format.js do
        render(json: Reply.find(params[:id])
                                    .attachments
                                    .map do |attachment|
                       { filename: attachment.filename,
                         id: attachment.id }
                     end)
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_reply
    @reply = Reply.find(params[:id])
  end

  # Never trust parameters from internet, only allow the white list through.
  def reply_params
    params.require(:reply).permit(:faq_attachments, :protocol,
                                  :description, :user_id, :faq, :files)
  end

  def filter_role
    action = params[:action]
    if %w[index destroy edit update show].include? action
      redirect_to denied_path unless admin?
    elsif %w[attachments].include? action
      redirect_to denied_path unless admin? || support_user?
    end
  end
end
