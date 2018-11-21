# frozen_string_literal: true

class AttachmentsController < ApplicationController
  protect_from_forgery
  before_action :set_attachment, only: %i[destroy download]
  before_action :filter_role
  include ApplicationHelper

  # GET /attachments
  # GET /attachments.json
  def index
    @attachments = Attachment.order(:id).paginate(page: params[:page], per_page: 25)
  end

  # POST /attachments
  def create
    @attachment = Attachment.new(attachment_params)

    if @attachment.save
      render json: { message: 'success', attachmentID: @attachment.id }, status: 200
    else
      render json: { message: 'error', error: @attachment.errors }, status: 501
    end
  end

  # DELETE /attachments/1
  def destroy
    if @attachment.attachment_links.length.zero?
      @attachment.destroy
      render json: { message: 'success' }, status: 200
    end
    render json: { message: 'Não será apagado, pois possui links' }, status: 200
  end

  # GET /attachment/:id/download
  def download
    if @attachment.filename != ''
      send_data(@attachment.file_contents, type: @attachment.content_type,
                                           filename: @attachment.filename)
    end
  rescue StandardError
    redirect_to not_found_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_attachment
    @attachment = Attachment.find(params[:id])
  end

  # Never trust parameters from internet, only allow the white list through.
  def attachment_params
    parameters = {}
    parameters[:id] = SecureRandom.uuid
    parameters[:filename] = params[:file].original_filename
    parameters[:content_type] = params[:file].content_type
    parameters[:file_contents] = params[:file].read
    parameters
  end

  def filter_role
    if params[:action] == 'download' && !admin? && !support_user?
      filter_roles_for_download
    else
      redirect_to not_found_path unless admin?
    end
  end

  def filter_roles_for_download
    @attachment.attachment_links.each do |link|
      downloadable?(link)
    end
  end

  def downloadable?(link)
    redirect_to denied_path if cant_download_answer(link, Call.where(answer_id: link.answer_id)
                                                              .first)
    redirect_to denied_path if cant_download_reply link, Call.find(link.reply.protocol)
    redirect_to denied_path if cant_download_call(link)
  end

  def cant_download_answer(link, call)
    !link.answer.try(:faq) &&
      ((current_user.company_admin? && call.sei != current_user.sei) ||
       (current_user.company_user? && call.user_id != current_user.id))
  end

  def cant_download_reply(link, call)
    link.reply? &&
      ((current_user.company_admin? && call.sei != current_user.sei) ||
       (current_user.company_user? && call.user_id != current_user.id))
  end

  def cant_download_call(link)
    link.call? &&
      ((current_user.company_admin? && link.call.sei != current_user.sei) ||
       (current_user.company_user? && link.call.user_id != current_user.id))
  end
end
