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
    action = params[:action]
    if action == 'edit'
      redirect_to denied_path unless admin?
    elsif action == 'download'
      sei = current_user.sei
      links = @attachment.attachment_links
      unless admin? || support_user?
        if company_user?
          links.each do |link|
            # Answer check
            if link.answer? &&
               !link.answer.faq &&
               ((current_user.try(:company_admin?) &&
                 Call.where(answer_id: link.answer_id).first.sei != sei) ||
                (current_user.try(:company_user?) &&
                 Call.where(answer_id: link.answer_id).first.user_id != id))
              redirect_to denied_path
            end

            # Reply check
            if link.reply? &&
               ((current_user.try(:company_admin?) &&
                 Call.find(link.reply.protocol).sei != sei) ||
                (current_user.try(:company_user?) &&
                 Call.find(link.reply.protocol).user_id != id))
              redirect_to denied_path
            end

            # Call check
            next unless link.call? &&
                        ((current_user.try(:company_admin?) &&
                          link.call.sei != sei) ||
                         (current_user.try(:company_user?) &&
                          link.call.user_id != id))

            redirect_to denied_path
          end
        else
          redirect_to denied_path
        end
      end
    end
  end
end
