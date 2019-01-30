# frozen_string_literal: true

##
# This is the controller for the Attachment model
#
# It is responsible for handling the views for any Attachment
class AttachmentsController < ApplicationController
  include ApplicationHelper
  protect_from_forgery

  # Hooks Configuration
  before_action :set_attachment, only: %i[destroy download]
  before_action :authenticate_user!, except: %i[create destroy]

  # CanCanCan Configuration
  load_and_authorize_resource
  skip_authorize_resource except: :index

  ####
  # :section: View methods
  # Method related to generating views
  ##

  # Configures the <tt>index</tt> page for the Attachment model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/attachments</tt>
  # [GET] <tt>/attachments.json</tt>
  def index
    @attachments = Attachment.paginate(page: params[:page], per_page: 25)
  end

  # Configures the <tt>POST</tt> request to create
  # a new Attachment
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/attachments</tt>
  def create
    @attachment = Attachment.new(attachment_params)

    if @attachment.save
      render json: { message: 'success', attachmentID: @attachment.id }, status: 200
    else
      render json: { message: 'error', error: @attachment.errors }, status: 501
    end
  end

  # Configures the <tt>DELETE</tt> request to delete
  # a Attachment <b>if he doesn't have any
  # AttachmentLink instances related to him</b>
  #
  # <b>ROUTES</b>
  #
  # [DELETE] <tt>/attachments/:id</tt>
  def destroy
    if @attachment.attachment_links.length.zero?
      @attachment.destroy
      return render(json: { message: 'success' },
                    status: 200)
    end
    render json: { message: 'Não será apagado, pois possui links' }, status: 200
  end

  # Configures the <tt>download</tt> request for a Attachment
  #
  # It prompts the browser to download the file
  # from the system
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/attachments/:id/download</tt>
  def download
    authorize! :download, @attachment

    send_attachment_data if @attachment.filename != ''
  end

  private

  ####
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file
  ##

  # Configures the Attachment instance when called by
  # the <tt>:before_action</tt> hook
  def set_attachment
    @attachment = Attachment.find(params[:id])
  end

  #####
  # :section: Custom private method
  ##

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def attachment_params
    parameters = {}
    parameters[:id] = SecureRandom.uuid
    parameters[:filename] = params[:file].original_filename
    parameters[:content_type] = params[:file].content_type
    parameters[:file_contents] = IO.binread(params[:file].to_io)
    parameters
  end

  # Called by #download, configures the file which will be sent to be downloaded
  def send_attachment_data
    send_data(@attachment.file_contents, type: @attachment.content_type,
                                         filename: @attachment.filename)
  end

  # CanCanCan Method
  #
  # Default CanCanCan Method, declaring the AttachmentAbility
  def current_ability
    @current_ability ||= AttachmentAbility.new(current_user, @attachment)
  end
end
