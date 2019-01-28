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
    files = retrieve_files_from(params) || []

    @feedback = Feedback.new(feedback_params)
    authorize! :create, @feedback

    if @feedback.save && @feedback.controversy.save
      update_controversy
      create_file_links files
      send_mails

      redirect_to controversy_path(@feedback.controversy),
                  notice: 'Controvérsia encerrada com sucesso.'
    else
      render :new,
             alert: 'A controvérsia não pode ser fechada. Tente novamente ou contate os devs'
    end
  rescue AttachmentLink::CreateError => e
    @feedback.delete # Rollback
    @feedback.controversy.open!
    @feedback.controversy.update!(closed_at: nil)
    render :new, alert: e.msg.concat('a esse Parecer final')
  rescue Event::CreateError => e
    @feedback.delete
    render :new, alert: e.msg.concat('durante a criação do Parecer Final da Controvérsia')
  rescue Alteration::CreateError => e
    @feedback.delete
    render :new, alert: e.msg.concat('durante a criação do Parecer Final da Controvérsia')
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
  def retrieve_files_from(parameters)
    parameters[:feedback].delete(:files).split(',') if parameters[:feedback][:files]
  end

  # For each Attachment instance id received in the
  # <tt>files</tt> parameter, creates the AttachmentLink
  # between the Feedback instance and the Attachment instance.
  def create_file_links(files)
    @links = []

    files.each do |file_uuid|
      @link = AttachmentLink.new(attachment_id: file_uuid, feedback_id: @feedback.id,
                                 source: 'feedback')

      raise AttachmentLink::CreateError unless @link.save

      @links.push(@link) # To handle the rollback
    end
  end

  # Called by #create, configures the Feedback's Controversy
  # parent instance, closing it
  def update_controversy
    configure_event :close_controversy, @feedback.controversy.support_1

    @feedback.controversy.closed!
    @feedback.controversy.update!(closed_at: 0.seconds.from_now)
  end

  # Configures a Event and an Alteration creation, when called by #update_controversy
  def configure_event(event, user)
    # Create event
    @event = Event.new(type: EventType.alteration,
                       user: user,
                       system: System.controversy,
                       protocol: @feedback.controversy.protocol)

    raise Event::CreateError unless @event.save

    # After we correctly saved the event
    @alteration = Alteration.new(id: @event.id, type: event)
    raise Alteration::CreateError unless @alteration.save
  end

  # Called by #create, it is the responsible for sending
  # emails to all the users involved in the Feedback's
  # Controversy parent instance
  def send_mails
    @feedback.controversy.involved_users.each do |user|
      FeedbackMailer.notify(@feedback.id, user.id).deliver_later
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
