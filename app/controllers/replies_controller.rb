# frozen_string_literal: true

##
# This is the controller for the Reply model
#
# It is responsible for handling the views for any Reply
class RepliesController < ApplicationController
  include ApplicationHelper

  # Hooks Configuration
  before_action :authenticate_user!

  ####
  # :section: View methods
  # Method related to generating views
  ##

  # Configures the <tt>index</tt> page for the Reply model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/replies</tt>
  # [GET] <tt>/replies.json</tt>
  def index
    (@filterrific = initialize_filterrific(
      Reply,
      params[:filterrific],
      persistence_id: false
    )) || return

    @replies = filterrific_query
    authorize! :index, Reply
  end

  # Configures the <tt>show</tt> page for the Reply model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/replies/:id</tt>
  # [GET] <tt>/replies/:id.json</tt>
  def show
    @reply = Reply.find(params[:id])
    authorize! :show, @reply
  end

  # Configures the <tt>POST</tt> request to create a new Reply
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/replies</tt>
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

  # Configures the <tt>attachments</tt> request for the
  # Reply model. It returns all Attachment instances which
  # belongs to the queried Reply
  #
  # <b>OBS.:</b> This view only exist in a JSON format
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/replies/:id/attachments.json</tt>
  def attachments
    @reply = Reply.find(params[:id])
    authorize! :verify_attachments, @reply

    @attachments = @reply.attachments
                         .map do |attachment|
      { filename: attachment.filename,
        type: attachment.content_type,
        id: attachment.id,
        bytes: retrieve_file_bytes(attachment) }
    end
  end

  private

  ####
  # :section: Custom private methods
  ##

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def reply_params
    params.require(:reply).permit(:faq_attachments, :repliable_id, :repliable_type,
                                  :description, :user_id, :faq, :files)
  end

  # Returns the Attachment instances's ids received in the
  # request, removing it from the parameters
  def retrieve_files(rep_params)
    rep_params[:files] ? rep_params.delete(:files).split(',') : []
  end

  # Called by #create, create a Reply based in the
  # <tt>params</tt> and setting some default values
  def create_reply(rep_params)
    reply = Reply.new(rep_params)
    reply.user_id = current_user.id
    reply.status = reply.repliable.try(:status) || 'Sem Status'
    reply
  end

  # For each Attachment instance id received in the
  # <tt>files</tt> parameter, creates the AttachmentLink
  # between the REply instance and the Attachment instance.
  def create_file_links(reply, files)
    files.each do |file_uuid|
      @link = AttachmentLink.new(attachment_id: file_uuid, reply_id: reply.id, source: 'reply')

      unless @link.save
        raise 'Não consegui criar o link entre arquivo e a resposta.'\
              ' Por favor tente mais tarde'
      end
    end
  end

  # Called by #attachments, query the database to know
  # what is the size in bytes of the Attachment instance
  # passed as parameter
  def retrieve_file_bytes(attachment)
    Reply.connection
         .select_all(Reply.sanitize_sql_array([
                                                'SELECT octet_length(file_contents) FROM '\
                                                '"TB_ANEXO" WHERE "TB_ANEXO"."CO_ID" = ?',
                                                attachment.id
                                              ]))[0]['octet_length']
  end

  # Called by #create, sends a email about the Reply
  # based if the Reply was created for a Call or a
  # Controversy instance
  def send_mail(reply, current_user)
    if reply.repliable.class.name == 'Call'
      ReplyMailer.call_reply(@reply, current_user).deliver_later
    else
      reply.repliable.all_users.each do |user|
        ReplyMailer.controversy_reply(@reply, current_user, user).deliver_later
      end
    end
  end

  # Called by #create, generates the redirect path
  # based if the Reply was created for a Call or a
  # Controversy instance
  def create_path(reply)
    id = reply.repliable_id
    reply.repliable_type == 'Call' ? call_path(id) : controversy_path(id)
  end

  ####
  # :section: CanCanCan methods
  # Methods which are related to the CanCanCan gem
  ##

  # CanCanCan Method
  #
  # Default CanCanCan Method, declaring the ReplyAbility
  def current_ability
    @current_ability ||= ReplyAbility.new(current_user)
  end
end
