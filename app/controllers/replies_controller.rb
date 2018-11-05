# frozen_string_literal: true

class RepliesController < ApplicationController
  before_action :set_reply, only: %i[show edit update destroy]
  before_action :authenticate_user!
  before_action :filter_role
  include ApplicationHelper

  # GET /replies
  def index
    (@filterrific = initialize_filterrific(
      Reply,
      params[:filterrific],
      select_options: { # em breve
      },
      persistence_id: false
    )) || return
    @replies = @filterrific.find.order(created_at: :desc).page(params[:page])
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
    files = retrieve_files rep_params
    @reply = create_reply rep_params

    if @reply.save
      create_file_links @reply, files
      send_mail @reply, current_user
      redirect_to create_path(@reply), notice: 'Resposta adicionada com sucesso.'
    else
      render :new
    end
  end

  # PATCH/PUT /replies/1
  def update
    if @reply.update(reply_params)
      redirect_to @reply, notice: 'Resposta atualizada com sucesso.'
    else
      render :edit
    end
  end

  # DELETE /replies/1
  def destroy
    @reply.destroy
    redirect_to replies_url, notice: 'Resposta apagada com sucesso.'
  end

  # GET /replies/attachments/:id
  def attachments
    respond_to do |format|
      format.js do
        render(json: Reply.find(params[:id])
                                    .attachments
                                    .map do |attachment|
                       { filename: attachment.filename,
                         type: attachment.content_type,
                         id: attachment.id,
                         bytes: retrieve_file_bytes(attachment) }
                     end)
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_reply
    @reply = Reply.find(params[:id])
  end

  def retrieve_files(rep_params)
    rep_params[:files] ? rep_params.delete(:files).split(',') : []
  end

  def create_reply(rep_params)
    reply = Reply.new(rep_params)
    reply.user_id = current_user.id
    reply.status = reply.repliable.status || 'Sem Status'
    reply.category = if support_user? || current_user.try(:admin?)
                       'support'
                     elsif company_user?
                       'company'
                     else
                       city_user? ? 'city' : 'unity'
                     end
    reply
  end

  def create_file_links(reply, files)
    files.each do |file_uuid|
      @link = AttachmentLink.new(attachment_id: file_uuid, reply_id: reply.id, source: 'reply')

      unless @link.save
        raise 'Não consegui criar o link entre arquivo e a resposta.'\
              ' Por favor tente mais tarde'
      end
    end
  end

  def retrieve_file_bytes(attachment)
    Reply.connection
         .select_all(Reply.sanitize_sql_array(
                       ['SELECT octet_length(file_contents) FROM '\
                        'attachments WHERE attachments.id = ?',
                        attachment.id]
                     ))[0]['octet_length']
  end

  def create_path(reply)
    id = reply.repliable_id
    reply.repliable_type == 'Call' ? call_path(id) : controversy_path(id)
  end

  def send_mail(reply, current_user)
    if reply.repliable.class.name == 'Call'
      CallReplyMailer.notify(@reply, current_user).deliver_later
    else
      reply.repliable.all_users.each do |user|
        ControversyReplyMailer.notify(@reply, current_user, user).deliver_later
      end
    end
  end

  # Never trust parameters from internet, only allow the white list through.
  def reply_params
    params.require(:reply).permit(:faq_attachments, :repliable_id, :repliable_type,
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
