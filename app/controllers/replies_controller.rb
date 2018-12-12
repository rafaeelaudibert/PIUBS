# frozen_string_literal: true

class RepliesController < ApplicationController
  before_action :authenticate_user!
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
    authorize! :index, Reply
  end

  # GET /replies/1
  def show
    @reply = Reply.find(params[:id])
    authorize! :show, @reply
  end

  # POST /replies
  def create
    rep_params = reply_params
    files = retrieve_files rep_params
    @reply = create_reply rep_params
    authorize! :create, @reply

    if @reply.save
      create_file_links @reply, files
      send_mail @reply, current_user
      redirect_to create_path(@reply), notice: 'Resposta adicionada com sucesso.'
    else
      render :new
    end
  end

  # GET /replies/attachments/:id
  def attachments
    @reply = Reply.find(params[:id])
    authorize! :verify_attachments, @reply

    respond_to do |format|
      format.js do
        render(json: @reply.attachments
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

  def create_params
    params.require(:reply).permit(:faq_attachments, :repliable_id, :repliable_type,
      :description, :user_id, :faq, :files)
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
      ReplyMailer.call_reply(@reply, current_user).deliver_later
    else
      reply.repliable.all_users.each do |user|
        ReplyMailer.controversy_reply(@reply, current_user, user).deliver_later
      end
    end
  end

  # Never trust parameters from internet, only allow the white list through.
  def reply_params
    params.require(:reply).permit(:faq_attachments, :repliable_id, :repliable_type,
                                  :description, :user_id, :faq, :files)
  end

  def current_ability
    @current_ability ||= ReplyAbility.new(current_user)
  end
end
