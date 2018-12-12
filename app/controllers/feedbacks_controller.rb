# frozen_string_literal: true

class FeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action :restrict_system!

  # GET /feedbacks
  def index
    @feedbacks = Feedback.all.page(params[:page])
    authorize! :index, Feedback
  end

  # GET /feedbacks/1
  def show
    @feedback = Feedback.find(params[:id])
    authorize! :show, @feedback
  end

  # POST /feedbacks
  # POST /feedbacks.json
  def create
    feedback_parameters = feedback_params

    files = retrieve_files(feedback_parameters) || []
    @feedback = Feedback.new(feedback_parameters)
    authorize! :create, @feedback

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

  def current_ability
    @current_ability ||= FeedbackAbility.new(current_user)
  end
end
