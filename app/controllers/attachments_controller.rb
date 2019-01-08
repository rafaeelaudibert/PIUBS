# frozen_string_literal: true

##
# This is the controller for the Attachment model
#
# It is responsible for handling the views for any Attachment
class AttachmentsController < ApplicationController
  include ApplicationHelper
  protect_from_forgery

  ##########################
  ## Hooks Configuration ###
  before_action :authenticate_user!
  before_action :filter_role
  before_action :set_attachment, only: %i[show edit update destroy download]

  ##########################
  # :section: View methods
  # Method related to generating views

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
  # [DELETE] <tt>/attachments/1</tt>
  def destroy
    if @attachment.attachment_links.length.zero?
      @attachment.destroy
      render json: { message: 'success' }, status: 200
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
    if @attachment.filename != ''
      send_data(@attachment.file_contents,
                type: @attachment.content_type,
                filename: @attachment.filename)
    end
  rescue StandardError
    redirect_to not_found_path
  end

  private

  ##########################
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file

  # Configures the Attachment instance when called by
  # the <tt>:before_action</tt> hook
  def set_attachment
    @attachment = Attachment.find(params[:id])
  end

  ##########################
  # :section: Custom private method

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def attachment_params
    parameters = {}
    parameters[:id] = SecureRandom.uuid
    parameters[:filename] = params[:file].original_filename
    parameters[:content_type] = params[:file].content_type
    parameters[:file_contents] = params[:file].read
    parameters
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Filters the access to each of the actions of the controller
  def filter_role
    if params[:action] == 'download' && !admin? && !support_user?
      filter_roles_for_download
    else
      redirect_to not_found_path unless admin?
    end
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Method called by #filter_role to verify if this
  # role cand download this attachment
  def filter_roles_for_download
    @attachment.attachment_links.each do |link|
      downloadable?(link)
    end
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Called by #filter_roles_for_download verifies if the
  # <tt>current_user</tt> can download the Attachment
  # related with the AttachmentLink passed as parameter
  def downloadable?(link)
    redirect_to denied_path if cant_download_answer(link,
                                                    Call.where(answer_id: link.answer_id)
                                                        .first)
    redirect_to denied_path if cant_download_reply link, Call.find(link.reply.protocol)
    redirect_to denied_path if cant_download_call(link)
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Called by #downloadable? verifies if the
  # <tt>current_user</tt> can download the Attachment
  # related with the AttachmentLink passed as parameter
  # knowing that it belongs to the Answer from the Call
  # also passed as parameter
  #
  # @returns [true] if the User <b>CANNOT</b> have access to this Answer Attachment
  #
  # <b>OBS: THIS IS EXTREMELY COMPLEX, AND PROBABLY DOESN'T WORK
  # CORRECTLY, AND WILL BE SAFELY REMOVED WHEN ADDING THE CANCANCAN GEM</b>
  def cant_download_answer(link, call)
    !link.answer.try(:faq) &&
      ((current_user.company_admin? && call.sei != current_user.sei) ||
       (current_user.company_user? && call.user_id != current_user.id))
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Called by #downloadable? verifies if the
  # <tt>current_user</tt> can download the Attachment
  # related with the AttachmentLink passed as parameter
  # knowing that it belongs to the Reply from the Call
  # also passed as parameter
  #
  # @returns [true] if the User <b>CANNOT</b> have access to this Reply Attachment
  #
  # <b>OBS: THIS IS EXTREMELY COMPLEX, AND PROBABLY DOESN'T WORK
  # CORRECTLY, AND WILL BE SAFELY REMOVED WHEN ADDING THE CANCANCAN GEM</b>
  def cant_download_reply(link, call)
    link.reply? &&
      ((current_user.company_admin? && call.sei != current_user.sei) ||
       (current_user.company_user? && call.user_id != current_user.id))
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Called by #downloadable? verifies if the
  # <tt>current_user</tt> can download the Attachment
  # related with the AttachmentLink passed as parameter
  # knowing that it belongs to the Call of the link
  #
  # @returns [true] if the User <b>CANNOT</b> have access to this Call Attachment
  #
  # <b>OBS: THIS IS EXTREMELY COMPLEX, AND PROBABLY DOESN'T WORK
  # CORRECTLY, AND WILL BE SAFELY REMOVED WHEN ADDING THE CANCANCAN GEM</b>
  def cant_download_call(link)
    link.call? &&
      ((current_user.company_admin? && link.call.sei != current_user.sei) ||
       (current_user.company_user? && link.call.user_id != current_user.id))
  end
end
