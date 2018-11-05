# frozen_string_literal: true

class FeedbacksController < ApplicationController
  before_action :set_feedback, only: %i[show edit update destroy]

  # GET /feedbacks
  # GET /feedbacks.json
  def index
    @feedbacks = Feedback.all
  end

  # GET /feedbacks/1
  # GET /feedbacks/1.json
  def show; end

  # GET /feedbacks/new
  def new
    @feedback = Feedback.new
  end

  # GET /feedbacks/1/edit
  def edit; end

  # POST /feedbacks
  # POST /feedbacks.json
  def create
    feedback_parameters = feedback_params

    files = retrieve_files(feedback_parameters) || []
    @feedback = Feedback.new(feedback_parameters)

    if @feedback.save && @feedback.controversy.save
      create_file_links @feedback, files
      update_controversy @feedback
      send_mails @feedback

      redirect_to controversy_path(@feedback.controversy),
                  notice: 'Controvérsia encerrada com sucesso.'
    else
      render :new,
             warn: 'A controvérsia não pode ser fechada. Tente novamente ou contate os devs'
    end
  end

  # PATCH/PUT /feedbacks/1
  # PATCH/PUT /feedbacks/1.json
  def update
    respond_to do |format|
      if @feedback.update(feedback_params)
        format.html { redirect_to @feedback, notice: 'Feedback was successfully updated.' }
        format.json { render :show, status: :ok, location: @feedback }
      else
        format.html { render :edit }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feedbacks/1
  # DELETE /feedbacks/1.json
  def destroy
    @feedback.destroy
    respond_to do |format|
      format.html { redirect_to feedbacks_url, notice: 'Feedback was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  def retrieve_files(parameters)
    parameters.delete(:files).split(',') if parameters[:files]
  end

  def create_file_links(feedback, files)
    files.each do |file_uuid|
      @link = AttachmentLink.new(attachment_id: file_uuid, feedback_id: feedback.id,
                                 source: 'feedback')
      unless @link.save
        raise 'Não consegui criar o link entre arquivo e o Feedback.'\
              ' Por favor tente mais tarde'
      end
    end
  end

  def update_controversy(feedback)
    feedback.controversy.closed!
    feedback.controversy.closed_at = Time.now
    feedback.controversy.save!
  end

  def send_mails(feedback)
    feedback.controversy.involved_users.each do |user|
      FeedbackMailer.notify(feedback.id, user.id).deliver_later
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def feedback_params
    params.require(:feedback).permit(:description, :controversy_id, :files)
  end
end
