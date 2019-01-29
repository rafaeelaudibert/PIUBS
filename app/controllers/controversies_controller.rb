# frozen_string_literal: true

##
# This is the controller for the Controversy model
#
# It is responsible for handling the views for any Controversy
class ControversiesController < ApplicationController
  include ApplicationHelper

  # Hooks Configuration
  before_action :authenticate_user!
  before_action :restrict_system!
  before_action :set_controversy, except: %i[index new create]
  before_action :set_user, only: %i[unlink_controversy link_controversy
                                    link_company_user link_city_user
                                    link_unity_user link_support_user]
  before_action :authorize_alter_user, only: %i[link_company_user link_city_user
                                                link_unity_user link_support_user]

  ####
  # :section: View methods
  # Method related to generating views
  ##

  # Configures the <tt>index</tt> page for the Answer model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/controversias/controversies</tt>
  # [GET] <tt>/controversias/controversies.json</tt>
  def index
    (@filterrific = initialize_filterrific(
      Controversy,
      params[:filterrific],
      persistence_id: false
    )) || return

    authorize! :index, Controversy
    @controversies = filtered_controversies
  end

  # Configures the <tt>show</tt> page for the Controversy model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/controversias/controversies/:id</tt>
  # [GET] <tt>/controversias/controversies/:id.json</tt>
  def show
    @reply = Reply.new
    @feedback = Feedback.new
    @user_creator = @controversy&.creator&.name || 'Sem usuário criador (Relate ao suporte)'
    authorize! :show, @controversy
  end

  # Configures the <tt>new</tt> page for the Controversy model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/controversias/controversies/new</tt>
  def new
    @controversy = Controversy.new
    authorize! :new, @controversy
    if (city_user? || ubs_user?) && current_user.city.contract_id.nil?
      redirect_back(fallback_location: controversies_path,
                    notice: 'A sua cidade não possui contratos')
    end
  end

  # Configures the <tt>POST</tt> request to create a new Controversy
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/controversies</tt>
  def create
    files = prepare_to_create(controversy_params)

    raise Controversy::CreateError unless @controversy.save

    post_creation_stuff(files)

    redirect_to @controversy, notice: 'Controvérsia criada com sucesso.'
  rescue Controversy::CreateError => e
    render :new, alert: e.message
  rescue AttachmentLink::CreateError => e
    @controversy.delete # Rollback
    render :new, alert: e.message + 'a essa Controvérsia'
  rescue Event::CreateError => e
    @controversy.delete # Rollback
    render :new, alert: e.message + 'durante a criação da Controvérsia'
  rescue Alteration::CreateError => e
    @controversy.delete # Rollback
    render :new, alert: e.message + 'durante a criação da Controvérsia'
  end

  # Configures the <tt>POST</tt> request to link
  # a <tt>support user</tt> to the Controversy
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/controversies/:id/link_controversy/:user_id</tt>
  def link_controversy
    configure_link_controversy
    redirect_back(fallback_location: root_path, notice: 'Agora essa controvérsia é sua')
  rescue Controversy::AlreadyTaken => e
    redirect_back(fallback_location: root_path, alert: e.message)
  rescue Controversy::UpdateError
    redirect_back(fallback_location: root_path, alert: e.message)
  rescue Event::CreateError => e
    @controversy.update(support_1: nil)
    redirect_back(fallback_location: root_path,
                  alert: e.message + 'durante a associação do suporte da Controvérsia')
  rescue Alteration::CreateError => e
    @controversy.update(support_1: nil)
    redirect_back(fallback_location: root_path,
                  alert: e.message + 'durante a associação do suporte da Controvérsia')
  end

  # Configures the <tt>POST</tt> request to unlink
  # a <tt>support user</tt> to the Controversy
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/controversies/:id/unlink_controversy/:user_id</tt>
  def unlink_controversy
    configure_unlink_controversy
    redirect_back(fallback_location: root_path, notice: 'A Controvérsia foi liberada')
  rescue Controversy::OwnerError => e
    redirect_back(fallback_location: root_path, alert: e.message)
  rescue Controversy::UpdateError => e
    redirect_back(fallback_location: root_path, alert: e.message)
  rescue Event::CreateError => e
    @controversy.update(support_1: @user)
    redirect_back(fallback_location: root_path,
                  alert: e.message + 'durante a desassociação do suporte')
  rescue Alteration::CreateError => e
    @controversy.update(support_1: @user)
    redirect_back(fallback_location: root_path,
                  alert: e.message + 'durante a desassociação do suporte')
  end

  # Configures the <tt>POST</tt> request to link or unlink
  # a <tt>company user</tt> to the Controversy
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/controversies/:id/link_company_user/:user_id</tt>
  def link_company_user
    handle_link_user(!@controversy.company_user.nil?, @user.sei == @controversy.sei,
                     @controversy.company_user, 'company_user', 'Usuário da Empresa')
  rescue Controversy::UserUpdateError => e
    [@event, @alteration].each(&:delete) # Rollback
    redirect_back(fallback_location: root_path, alert: e.message)
  rescue Event::CreateError => e
    redirect_back(fallback_location: root_path,
                  alert: e.message + 'durante a alteração do usuário da Empresa')
  rescue Alteration::CreateError => e
    redirect_back(fallback_location: root_path,
                  alert: e.message + 'durante a alteração do usuário da Empresa')
  end

  # Configures the <tt>POST</tt> request to link or unlink
  # a <tt>city user</tt> to the Controversy
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/controversies/:id/link_city_user/:user_id</tt>
  def link_city_user
    handle_link_user(!@controversy.city_user.nil?, city_user_elegible?,
                     @controversy.city_user, 'city_user', 'Usuário da Cidade')
  rescue Controversy::UserUpdateError => e
    [@event, @alteration].each(&:delete) # Rollback
    redirect_back(fallback_location: root_path, alert: e.message)
  rescue Event::CreateError => e
    redirect_back(fallback_location: root_path,
                  alert: e.message + 'durante a alteração do usuário da Cidade'
                 )
  rescue Alteration::CreateError => e
    redirect_back(fallback_location: root_path,
                  alert: e.message + 'durante a alteração do usuário da Cidade'
                 )
  end

  # Configures the <tt>POST</tt> request to link or unlink
  # a <tt>unity user</tt> to the Controversy
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/controversies/:id/link_unity_user/:user_id</tt>
  def link_unity_user
    handle_link_user(!@controversy.unity_user.nil?, unity_user_elegible?,
                     @controversy.unity_user, 'unity_user', 'Usuário da UBS')
  rescue Controversy::UserUpdateError => e
    [@event, @alteration].each(&:delete) # Rollback
    redirect_back(fallback_location: root_path, alert: e.message)
  rescue Event::CreateError => e
    redirect_back(fallback_location: root_path,
                  alert: e.message + 'durante a alteração do usuário da UBS')
  rescue Alteration::CreateError => e
    @event.delete # Rollback
    redirect_back(fallback_location: root_path,
                  alert: e.message + 'durante a alteração do usuário da UBS')
  end

  # Configures the <tt>POST</tt> request to link or unlink
  # a extra <tt>support user</tt> to the Controversy
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/controversies/:id/link_support_user/:user_id</tt>
  def link_support_user
    handle_link_user(!@controversy.support_2.nil?, support_like?(@user),
                     @controversy.support_2, 'support_2', 'Usuário extra do Suporte')
  rescue Controversy::UserUpdateError => e
    [@event, @alteration].each(&:delete) # Rollback
    redirect_back(fallback_location: root_path, alert: e.message)
  rescue Event::CreateError => e
    redirect_back(fallback_location: root_path,
                  alert: e.message + 'durante a alteração do suporte extra da Controvérsia')
  rescue Alteration::CreateError => e
    @event.delete # Rollback
    redirect_back(fallback_location: root_path,
                  alert: e.message + 'durante a alteração do suporte extra da Controvérsia')
  end

  private

  ####
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file
  ##

  # Configures a Event and an Alteration creation
  def configure_event(event, user)
    # Create event
    @event = Event.new(type: EventType.alteration,
                       user: user,
                       system: System.controversy,
                       protocol: @controversy.protocol)

    # raise Event::CreateError
    raise Event::CreateError unless @event.save

    # After we correctly saved the event
    @alteration = Alteration.new(id: @event.id, type: event)
    raise Alteration::CreateError, event: @event unless @alteration.save
  end

  # Configures the Controversy instance when called by
  # the <tt>:before_action</tt> hook
  def set_controversy
    @controversy = Controversy.find(params[:id])
  end

  # Configures the User instance when called by
  # the <tt>:before_action</tt> hook
  def set_user
    @user = User.find(params[:user_id])
  end

  # Restrict the access to the views according to the
  # <tt>current_user system</tt>, as it must have access
  # to the Apoio as Empresas system.
  # It is called by a <tt>:before_action</tt> hook
  def restrict_system!
    redirect_to denied_path unless current_user.both? || current_user.controversies?
  end

  # Restrict the User instances which can make <tt>alter_user</tt>
  # actions in the system.
  # It is called by a <tt>:before_action</tt> hook, but it is also
  # a CanCanCan method
  def authorize_alter_user
    authorize! :alter_user, @controversy
  end

  ####
  # :section: Filterrific methods
  # Method related to the Filterrific Gem
  ##

  # Filterrific method
  #
  # Returns all the Controversy instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>support_user</tt> role,
  # which is handled by the calling function
  def controversies_for_support_user
    filterrific_query.from_support_user [current_user.id, nil]
  end

  # Filterrific method
  #
  # Returns all the Controversy instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>support_admin</tt> role,
  # which is handled by the calling function
  def controversies_for_support_admin
    filterrific_query.from_support_user [User.invited_by(current_user.id).map(&:id),
                                         current_user.id,
                                         nil].flatten
  end

  # Filterrific method
  #
  # Returns all the Controversy instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>company_admin</tt> role,
  # which is handled by the calling function
  def controversies_for_company_admin
    filterrific_query.from_company current_user.sei
  end

  # Filterrific method
  #
  # Returns all the Controversy instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>company_user</tt> role,
  # which is handled by the calling function
  def controversies_for_company_user
    filterrific_query.from_company_user current_user.id
  end

  # Filterrific method
  #
  # Returns all the Controversy instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>city_admin</tt> role,
  # which is handled by the calling function
  def controversies_for_city
    filterrific_query.from_city current_user.city_id
  end

  # Filterrific method
  #
  # Returns all the Controversy instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>ubs_admin</tt> role,
  # which is handled by the calling function
  def controversies_for_unity
    filterrific_query.from_unity_user current_user.id
  end

  ####
  # :section: Custom private methods
  ##

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def controversy_params
    params.require(:controversy).permit(:title, :description, :protocol, :closed_at, :sei,
                                        :contract_id, :city_id, :cnes, :company_user_id,
                                        :unity_user_id, :category, :complexity, :category_id,
                                        :support_1_id, :support_2_id, :user_creator, :feedback,
                                        :files)
  end

  # Returns the Attachment instances's ids received in the
  # request, removing it from the parameters
  def retrieve_files_from(parameters)
    parameters.delete(:files).split(',') if parameters[:files]
  end

  # Returns the User creator received in the
  # request, removing it from the parameters
  def retrieve_user_creator(parameters)
    parameters.delete(:user_creator) if parameters[:user_creator]
  end

  # Called by #create, configures the Controversy creation
  def prepare_to_create(parameters)
    files = retrieve_files_from(parameters)
    user_creator = retrieve_user_creator(parameters)
    @controversy = create_controversy(parameters, user_creator)
    authorize! :create, @controversy

    files
  end

  # Returns a Controversy with the <tt>parameters</tt>
  # received in the request filled, as well as the
  # <tt>creator</tt>, <tt>creator_user_id</tt> and
  # <tt>support_1_user_id</tt> fields filled
  def create_controversy(parameters, creator_id)
    user_id = creator_id || current_user.id
    role = Controversy.map_role_to_creator(user_id)

    controversy = Controversy.new(parameters)
    controversy.creator_id ||= user_id
    controversy.send(role + '_user_id=', user_id)
    controversy.support_1_user_id = current_user.id if support_user?

    controversy
  end

  # Called by #create, handles all the Controversy action to be executed
  # after the Controversy creation
  def post_creation_stuff(files)
    create_file_links files
    configure_event :open_call, @controversy.creator
    configure_event :link_support_controversy, current_user
    ControversyMailer.new_controversy(@controversy.protocol, @controversy.creator.id).deliver_later
  end

  # Called by #link_city_user verifies if the User trying to
  # be added as <tt>city_user</tt> of this Controversy instance
  # can be added as it, as it should belong to the same City
  # as the Controversy is related to
  def city_user_elegible?
    @user.city_id == @controversy.city_id && @user.cnes.nil?
  end

  # Called by #link_unity_user verifies if the User trying to
  # be added as <tt>unity_user</tt> of this Controversy instance
  # can be added as it, as it should belong to the same Unity
  # as the Unity is related to, OR, if the Controversy is not
  # related to any Unity, he should belong to a Unity related
  # with the City which is related to the Controversy
  def unity_user_elegible?
    (@controversy.cnes.nil? && @user.city_id == @controversy.city_id) ||
      @user.cnes == @controversy.cnes
  end

  # Method called by #link_controversy which makes the link between
  # the User instance with a <tt>support_like</tt> role to the Controversy
  def configure_link_controversy
    authorize! :link, @controversy

    raise Controversy::AlreadyTaken unless @controversy.support_1.nil?
    raise Controversy::UpdateError unless support_like?(@user)
    raise Controversy::UpdateError unless @controversy.update(support_1: @user)

    configure_event :link_support_controversy, @user
  end

  # Method called by #unlink_controversy which destroys the link between
  # the User instance located in the <tt>support_1</tt> field to the Controversy
  def configure_unlink_controversy
    authorize! :link, @controversy

    raise Controversy::OwnerError unless @controversy.support_1 == @user
    raise Controversy::UpdateError unless @controversy.update(support_1: nil)

    configure_event :unlink_support_controversy, @user
  end

  # Function called by the methods which handle Controversy links for
  # User instances which can belong to a City, Unity, Company or the support
  def handle_link_user(unlink_bool, link_bool, actual_user, role, msg)
    if unlink_bool # Unlinking Company user
      unlink_user_function(actual_user, role, msg)
    elsif link_bool # Linking Company user
      link_user_function(role, msg)
    else
      redirect_back(fallback_location: root_path,
                    alert: 'Usuário sem permissão para ser adicionado')
    end
  end

  # Function called by #handle_link_user to handle the unlink part of the job
  def unlink_user_function(actual_user, role, msg)
    configure_event "unlink_#{role}_controversy".to_sym, actual_user

    raise Controversy::UserUpdateError unless @controversy.send('update', "#{role}": nil)

    redirect_back(fallback_location: root_path, notice: "#{msg} removido com sucesso")
  end

  # Function called by #handle_link_user to handle the link part of the job
  def link_user_function(role, msg)
    configure_event "link_#{role}_controversy".to_sym, @user

    raise Controversy::UserUpdateError unless @controversy.send('update', "#{role}": @user)

    ControversyMailer.user_added(@controversy.id, @user.id).deliver_later
    redirect_back(fallback_location: root_path, notice: "#{msg} adicionado com sucesso")
  end

  # Checks which are the controversies which can be
  # seen by this user
  def filtered_controversies
    if support_user?
      current_user.call_center_user? ? controversies_for_support_user : controversies_for_support_admin
    elsif company_user?
      current_user.company_admin? ? controversies_for_company_admin : controversies_for_company_user
    elsif city_user?
      controversies_for_city
    elsif unity_user?
      controversies_for_unity
    elsif admin?
      filterrific_query
    else
      []
    end
  end

  # For each Attachment instance id received in the
  # <tt>files</tt> parameter, creates the AttachmentLink
  # between the Controversy instance and the Attachment instance.
  def create_file_links(files)
    links = []

    files.each do |file_uuid|
      link = AttachmentLink.new(attachment_id: file_uuid,
                                controversy_id: @controversy.protocol,
                                source: 'controversy')

      raise AttachmentLink::CreateError, links: links unless link.save

      links.push(link)  # To handle the rollback
    end
  end

  ####
  # :section: CanCanCan methods
  # Methods which are related to the CanCanCan gem
  ##

  # CanCanCan Method
  #
  # Default CanCanCan Method, declaring the ControversyAbility
  def current_ability
    @current_ability ||= ControversyAbility.new(current_user)
  end
end
