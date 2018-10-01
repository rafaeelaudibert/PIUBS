# frozen_string_literal: true

class AttachmentsController < ApplicationController
  before_action :set_attachment, only: %i[show edit update destroy download]
  before_action :filter_role
  include ApplicationHelper

  # GET /attachments
  # GET /attachments.json
  def index
    @attachments = Attachment.order('id').paginate(page: params[:page], per_page: 25)
  end

  # GET /attachments/1
  def show; end

  # GET /attachments/new
  def new
    @attachment = Attachment.new
  end

  # GET /attachments/1/edit
  def edit; end

  # POST /attachments
  def create
    parsed_params = attachment_params
    parsed_params[:filename].each_with_index do |_filename, _index|
      @attachment = Attachment.new(eachAttachment(parsed_params, _index))
      raise 'Não consegui anexar o arquivo. Por favor tente mais tarde' unless @attachment.save
    end

    if @attachment.save
      redirect_to @attachment, notice: 'Attachment was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /attachments/1
  def update
    if @attachment.update(attachment_params)
      redirect_to @attachment, notice: 'Attachment was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /attachments/1
  def destroy
    @attachment.destroy
    redirect_to attachments_url, notice: 'Attachment was successfully destroyed.'
  end

  # GET /attachment/:id/download
  def download
    send_data(@attachment.file_contents, type: @attachment.content_type, filename: @attachment.filename) if @attachment.filename != ''
  rescue StandardError
    redirect_to not_found_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_attachment
    @attachment = Attachment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def attachment_params
    parameters = params.require(:attachment).permit(:id, :source, file: [])
    file = parameters.delete(:file) if parameters
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
    pp new_params
    new_params
  end

  def filter_role
    action = params[:action]
    if %w[index show edit update].include? action
      redirect_to denied_path unless is_admin?
    elsif action == 'download'
      user_id = current_user.id
      sei = current_user.sei
      links = @attachment.attachment_links
      unless is_admin? || is_support_user?
        if is_company_user
          links.each do |_link|
            # Answer check
            redirect_to denied_path if _link.answer? && !_link.answer.faq && ((current_user.try(:company_admin?) && Call.where(answer_id: _link.answer_id).first.sei != sei) || (current_user.try(:company_user?) && Call.where(answer_id: _link.answer_id).first.user_id != id))

            # Reply check
            redirect_to denied_path if _link.reply? && ((current_user.try(:company_admin?) && Call.find(_link.reply.protocol).sei != sei) || (current_user.try(:company_user?) && Call.find(_link.reply.protocol).user_id != id))

            # Call check
            redirect_to denied_path if _link.call? && ((current_user.try(:company_admin?) && _link.call.sei != sei) || (current_user.try(:company_user?) && _link.call.user_id != id))
          end
        else
          redirect_to denied_path
        end
      end
    end
  end
end
