# frozen_string_literal: true

##
# This is the controller for the Call model
#
# It is responsible for handling the views for any Call
class CallsController < ApplicationController
  include ApplicationHelper

  # Hooks Configuration
  before_action :authenticate_user!
  before_action :restrict_system!
  before_action :set_company, only: %i[create new]
  before_action :set_call, except: %i[index new create]

  # CanCanCan Configuration
  authorize_resource
  skip_authorize_resource only: %i[link_call_support_user unlink_call_support_user reopen_call]

  ####
  # :section: View methods
  # Method related to generating views
  ##

  # Configures the <tt>index</tt> page for the Call model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/apoioaempresas/calls</tt>
  # [GET] <tt>/apoioaempresas/calls.json</tt>
  def index
    (@filterrific = initialize_filterrific(Call, params[:filterrific],
                                           select_options: options_for_filterrific,
                                           persistence_id: false)) || return
    @calls = filtered_calls
  end

  # Configures the <tt>show</tt> page for the Call model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/apoioaempresas/calls/:id</tt>
  # [GET] <tt>/apoioaempresas/calls/:id.json</tt>
  def show
    @answer = Answer.new
    @reply = Reply.new
    @categories = Category.all
    @my_call = @call.support_user == current_user
    @user = User.find(@call.support_user_id) if @call.support_user_id
  end

  # Configures the <tt>new</tt> page for the Call model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/apoioaempresas/calls/new</tt>
  def new
    @call = Call.new
  end

  # Configures the <tt>POST</tt> request to create a new Call
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/apoioaempresas/calls</tt>
  def create
    handle_call_creation
  rescue Call::CreateError => e
    render :new, alert: e.message
  rescue AttachmentLink::CreateError => e
    [@alteration, @event, @call].each(&:delete) # Rollback
    render :new, alert: e.message + 'a esse Atendimento'
  rescue Event::CreateError => e
    @call.delete # Rollback
    render :new, alert: e.message + 'durante a criação do Atendimento'
  rescue Alteration::CreateError => e
    @call.delete # Rollback
    render :new, alert: e.message + 'durante a criação do Atendimento'
  end

  # Configures the <tt>POST</tt> request to link
  # a <tt>support user</tt> to the Call
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/apoioaempresas/calls/:id/link_call_support_user</tt>
  def link_call_support_user
    handle_link_call_support_user
  rescue Call::AlreadyTakenError => e
    redirect_back fallback_location: root_path, alert: e.message
  rescue Call::UpdateError => e
    [@alteration, @event].each(&:delete) # Rollback
    redirect_back fallback_location: root_path, alert: e.message
  rescue Event::CreateError => e
    redirect_back fallback_location: root_path,
                  alert: e.message + 'durante a associação do suporte ao Atendimento'
  rescue Alteration::CreateError => e
    redirect_back fallback_location: root_path,
                  alert: e.message + 'durante a associação do suporte ao Atendimento'
  end

  # Configures the <tt>POST</tt> request to unlink the
  # <tt>support user</tt> from the Call
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/apoioaempresas/calls/:id/unlink_call_support_user</tt>
  def unlink_call_support_user
    handle_unlink_call_support_user
  rescue Call::OwnerError => e
    redirect_back fallback_location: root_path, alert: e.message
  rescue Call::UpdateError => e
    [@alteration, @event].each(&:delete) # Rollback
    redirect_back fallback_location: root_path, alert: e.message
  rescue Event::CreateError => e
    redirect_back fallback_location: root_path,
                  alert: e.message + 'durante a desassociação do suporte ao Atendimento'
  rescue Alteration::CreateError => e
    redirect_back fallback_location: root_path,
                  alert: e.message + 'durante a desassociação do suporte ao Atendimento'
  end

  # Configures the <tt>POST</tt> request to reopen a once closed Call
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/apoioaempresas/calls/:id/reopen_call</tt>
  def reopen_call
    authorize! :reopen_call, @call

    handle_reopen_call
  rescue Call::UpdateError
    [@alteration, @event].each(&:delete) # Rollback
    redirect_back fallback_location: root_path,
                  alert: 'Ocorreu um erro ao tentar reabrir esse Atendimento'
  rescue Event::CreateError => e
    redirect_back fallback_location: root_path,
                  alert: e.message + 'durante a reabertura do Atendimento'
  rescue Alteration::CreateError => e
    redirect_back fallback_location: root_path,
                  alert: e.message + 'durante a reabertura do Atendimento'
  end

  private

  ####
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file
  ##

  # Configures the Call instance when called by
  # the <tt>:before_action</tt> hook
  def set_call
    @call = Call.find(params[:id])
  end

  # Configures the Company instance when called by
  # the <tt>:before_action</tt> hook
  def set_company
    @company = Company.find(current_user.sei) if current_user.sei
  end

  # Restrict the access to the views according to the
  # <tt>current_user system</tt>, as it must have access
  # to the Apoio as Empresas system
  # It is called by a <tt>:before_action</tt> hook
  def restrict_system!
    redirect_to denied_path unless current_user.both? || current_user.companies?
  end

  ####
  # :section: Filterrific methods
  # Method related to the Filterrific Gem
  ##

  # Filterrific method
  #
  # Configures the basic options for the
  # <tt>Filterrific</tt> queries
  def options_for_filterrific
    {
      sorted_by_creation: Call.options_for_sorted_by_creation,
      with_status: Call.options_for_with_status,
      with_state: retrieve_states_for_filterrific,
      with_city: [],
      with_ubs: [],
      with_company: Company.all.map(&:sei)
    }
  end

  # Filterrific method
  #
  # Configures the State instances which can be
  # used to sort the Call instances
  def retrieve_states_for_filterrific
    if current_user.cnes
      State.find(current_user.company
                             .contracts
                             .map(&:state)).map { |s| [s.name, s.id] }
    else
      State.all.map { |s| [s.name, s.id] }
    end
  end

  # Filterrific method
  #
  # Returns all the Call instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>support_user</tt> role,
  # which is handled by the calling function
  def calls_for_support_user
    filterrific_query.from_support_user [current_user.id, nil]
  end

  # Filterrific method
  #
  # Returns all the Call instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>support_admin</tt> role,
  # which is handled by the calling function
  def calls_for_support_admin
    filterrific_query.from_support_user [User.invited_by(current_user.id).map(&:id),
                                         current_user.id,
                                         nil].flatten
  end

  # Filterrific method
  #
  # Returns all the Call instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>company_admin</tt> role,
  # which is handled by the calling function
  def calls_for_company_admin
    filterrific_query.from_company current_user.sei
  end

  # Filterrific method
  #
  # Returns all the Call instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>company_user</tt> role,
  # which is handled by the calling function
  def calls_for_company_user
    filterrific_query.from_company_user current_user.id
  end

  ####
  # :section: Custom private methods
  ##

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def call_params
    params.require(:call).permit(:sei, :user_id, :title,
                                 :description, :finished_at, :version,
                                 :access_profile, :feature_detail,
                                 :answer_summary, :severity, :protocol,
                                 :city_id, :category_id,
                                 :company_id, :cnes)
  end

  # Called by #create, handles all the Call instance creation proccess
  def handle_call_creation
    files = retrieve_files_from params.require(:call)
    @call = create_call call_params

    raise Call::CreateError unless @call.save

    configure_event :open_call, @call.user
    create_file_links files

    redirect_to @call, notice: 'Atendimento criado com sucesso.'
  end

  # Called by #link_call_support_user, handles all the proccess to link
  # a User instance to a Call
  def handle_link_call_support_user
    authorize! :link_call, @call

    raise Call::AlreadyTakenError if @call.support_user

    configure_event :link_call, current_user
    raise Call::UpdateError unless @call.update(support_user: current_user)

    redirect_back fallback_location: root_path, notice: 'Agora esse Atendimento é seu'
  end

  # Called by #unlink_call_support_user, handles all the proccess to unlink
  # a User instance to a Call
  def handle_unlink_call_support_user
    raise Call::OwnerError unless @call.support_user == current_user

    configure_event :unlink_call, current_user
    raise Call::UpdateError unless @call.update(support_user: nil)

    redirect_back fallback_location: root_path, notice: 'Atendimento liberado com sucesso.'
  end

  # Called by #reopen_call, handles all the proccess to reopen a Call instance
  def handle_reopen_call
    @answer = @call.answer
    @call = update_call

    configure_event :reopen_call, current_user
    raise Call::UpdateError unless @call.save

    delete_final_answer unless @answer.try(:faq) == true

    redirect_back fallback_location: root_path, notice: 'Atendimento reaberto'
  end

  # Method called by #reopen_call function,
  # used to reopen a call and re-configure the timeline
  def update_call
    @call.reopened!
    @call.update(reopened_at: 0.seconds.from_now, answer_id: nil)
    @call
  end

  # Configures a Event and an Alteration creation
  def configure_event(event, user)
    # Create event
    @event = Event.new(type: EventType.alteration,
                       user: user,
                       system: System.call,
                       protocol: @call.protocol)

    raise Event::CreateError unless @event.save

    # After we correctly saved the event
    @alteration = Alteration.new(id: @event.id, type: event)
    raise Alteration::CreateError, event: @event unless @alteration.save
  end

  # Checks which are the calls which can be seen by this user
  def filtered_calls
    if support_user?
      current_user.call_center_user? ? calls_for_support_user : calls_for_support_admin
    elsif company_user?
      current_user.company_admin? ? calls_for_company_admin : calls_for_company_user
    elsif admin?
      filterrific_query
    else
      []
    end
  end

  # Returns a Call with the <tt>parameters</tt>
  # received in the request filled, as well as the
  # <tt>user_id</tt> and <tt>sei</tt> fields filled
  def create_call(call_parameters)
    @call = Call.new call_parameters
    @call.user_id ||= current_user.id
    @call.sei ||= current_user.sei

    @call
  end

  # Returns the Attachment instances's ids received in the
  # request, removing it from the parameters
  def retrieve_files_from(call_parameters)
    call_parameters.delete(:files).split(',') if call_parameters[:files]
  end

  # For each Attachment instance id received in the
  # <tt>files</tt> parameter, creates the AttachmentLink
  # between the Call instance and the Attachment instance.
  def create_file_links(files)
    links = []

    files.each do |file_uuid|
      link = AttachmentLink.new(attachment_id: file_uuid,
                                call_id: @call.id,
                                source: 'call')

      raise AttachmentLink::CreateError, links: links unless link.save

      links.push(link) # To handle the rollback
    end
  end

  # Delete each AttachmentLink for the Answer passed
  # in the <tt>answer</tt> parameter, as well as the
  # own Answer
  def delete_final_answer
    @answer.attachment_links.each(&:destroy)
    @answer.destroy # Destroi a resposta final anterior
  end

  ####
  # :section: CanCanCan methods
  # Methods which are related to the CanCanCan gem
  ##

  # CanCanCan Method
  #
  # Default CanCanCan Method, declaring the CallAbility
  def current_ability
    @current_ability ||= CallAbility.new(current_user)
  end
end
