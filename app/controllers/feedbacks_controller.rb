# frozen_string_literal: true

class FeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action :restrict_system!
  before_action :filter_role

  # GET /feedbacks
  # GET /feedbacks.json
  def index
    @feedbacks = Feedback.all
  end

  # GET /feedbacks/1
  # GET /feedbacks/1.json
  def show
    @feedback = Feedback.find(params[:id])
  end

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

  private

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
    feedback.controversy.closed_at = 0.seconds.from_now
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

  def restrict_system!
    redirect_to denied_path unless current_user.both? || current_user.controversies?
  end

  def filter_role
    redirect_to denied_path if %w[index show].include?(params[:action]) && !admin? && !support_user?
  end
end
