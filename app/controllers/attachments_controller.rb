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
    parsed_params[:filename].each_with_index do |_filename, index|
      @attachment = Attachment.new(each_attachment(parsed_params, index))
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
    redirect_to attachments_url,
                notice: 'Attachment was successfully destroyed.'
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
    parameters = params.require(:attachment).permit(:id, :source, file: [])
    file = parameters.delete(:file) if parameters
    if file
      parameters[:filename] = []
      parameters[:content_type] = []
      parameters[:file_contents] = []
      file.each do |f|
        parameters[:filename].append(File.basename(f.original_filename))
        parameters[:content_type].append(f.content_type)
        parameters[:file_contents].append(f.read)
      end
    end
    parameters
  end

  def each_attachment(parsed_params, index)
    new_params = {}
    new_params[:filename] = parsed_params[:filename][index]
    new_params[:content_type] = parsed_params[:content_type][index]
    new_params[:file_contents] = parsed_params[:file_contents][index]
    new_params
  end

  def filter_role
    action = params[:action]
    if %w[index show edit update].include? action
      redirect_to denied_path unless admin?
    elsif action == 'download'
      sei = current_user.sei
      links = @attachment.attachmentlinks
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
