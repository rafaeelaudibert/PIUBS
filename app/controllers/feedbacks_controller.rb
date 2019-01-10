# frozen_string_literal: true

##
# This is the controller for the Feedback model
#
# It is responsible for handling the views for any Feedback
class FeedbacksController < ApplicationController
  include ApplicationHelper

  # Hooks Configuration
  before_action :authenticate_user!
  before_action :restrict_system!

  ####
  # :section: View methods
  # Method related to generating views
  ##

  # Configures the <tt>index</tt> page for the Company model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/controversias/feedbacks</tt>
  # [GET] <tt>/controversias/feedbacks.json</tt>
  def index
    @feedbacks = Feedback.all.page(params[:page])
    authorize! :index, Feedback
  end

  # Configures the <tt>show</tt> page for the Company model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/controversias/feedbacks/:id</tt>
  # [GET] <tt>/controversias/feedbacks/:id.json</tt>
  def show
    @feedback = Feedback.find(params[:id])
    authorize! :show, @feedback
  end

  # Configures the <tt>POST</tt> request to create a new
  # Feedback
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/feedback</tt>
  def create
    files = retrieve_files(params) || []

    @feedback = Feedback.new(feedback_params)
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

  ####
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file
  ##

  # Restrict the access to the views according to the
  # <tt>current_user system</tt>, as it must have access
  # to the Solucao de Controversias system.
  # It is called by a <tt>:before_action</tt> hook
  def restrict_system!
    redirect_to denied_path unless current_user.both? || current_user.controversies?
  end

  ####
  # :section: Custom private methods
  ##

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def feedback_params
    params.require(:feedback).permit(:description, :controversy_id)
  end

  # Returns the Attachment instances's ids received in the
  # request, removing it from the parameters
  def retrieve_files(parameters)
    parameters.delete(:files).split(',') if parameters[:files]
  end

  # For each Attachment instance id received in the
  # <tt>files</tt> parameter, creates the AttachmentLink
  # between the Feedback instance and the Attachment instance.
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

  # Called by #create, configures the Feedback's Controversy
  # parent instance, closing it
  def update_controversy(feedback)
    feedback.controversy.closed!
    feedback.controversy.closed_at = 0.seconds.from_now
    feedback.controversy.save!
  end

  # Called by #create, it is the responsible for sending
  # emails to all the users involved in the Feedback's
  # Controversy parent instance
  def send_mails(feedback)
    feedback.controversy.involved_users.each do |user|
      FeedbackMailer.notify(feedback.id, user.id).deliver_later
    end
  end

  ####
  # :section: CanCanCan methods
  # Methods which are related to the CanCanCan gem
  ##

  # CanCanCan Method
  #
  # Default CanCanCan Method, declaring the FeedbackAbility
  def current_ability
    @current_ability ||= FeedbackAbility.new(current_user)
  end
end
