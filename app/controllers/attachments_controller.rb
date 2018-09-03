class AttachmentsController < ApplicationController
  before_action :set_attachment, only: %i[show edit update destroy download]

  # GET /attachments
  # GET /attachments.json
  def index
    @attachments = Attachment.paginate(page: params[:page], per_page: 25)
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
end
