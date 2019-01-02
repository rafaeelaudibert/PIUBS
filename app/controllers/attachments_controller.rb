# frozen_string_literal: true

class AttachmentsController < ApplicationController
  protect_from_forgery
  before_action :set_attachment, only: %i[show edit update destroy download]
  before_action :authenticate_user!, except: %i[create destroy]
  include ApplicationHelper

  load_and_authorize_resource
  skip_authorize_resource except: :index

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
      return render(json: { message: 'success' },
                    status: 200)
    end
    render json: { message: 'Não será apagado, pois possui links' }, status: 200
  end

  # GET /attachment/:id/download
  def download
    authorize! :download, @attachment

    send_attachment_data if @attachment.filename != ''
  end

  private

  def send_attachment_data
    send_data(@attachment.file_contents, type: @attachment.content_type,
                                         filename: @attachment.filename)
  end

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

  def current_ability
    @current_ability ||= AttachmentAbility.new(current_user, @attachment)
  end
end
