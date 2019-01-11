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
  before_action :set_user, only: %i[link_company_user link_city_user
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

    @controversies = filterrific_query
    authorize! :index, Controversy
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
    @user_creator = begin
                      User.find(@controversy.send("#{@controversy.creator}_user_id")).name
                    rescue StandardError
                      'Sem usuário criador (Relate ao suporte)'
                    end
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
    # rubocop:enable Style/GuardClause
  end

  # Configures the <tt>POST</tt> request to create a new Controversy
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/controversies</tt>
  def create
    controversy_parameters = controversy_params

    files = retrieve_files controversy_parameters
    user_creator = retrieve_user_creator controversy_parameters
    @controversy = create_controversy controversy_parameters, user_creator
    authorize! :create, @controversy

    if @controversy.save
      create_file_links @controversy, files
      ControversyMailer.new_controversy(@controversy.protocol, current_user.id).deliver_later
      redirect_to @controversy, notice: 'Controvérsia criada com sucesso.'
    else
      render :new
    end
  end

  # Configures the <tt>POST</tt> request to link
  # a <tt>support user</tt> to the Controversy
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/controversies/:id/link_controversy/:user_id</tt>
  def link_controversy
    authorize! :link, @controversy

    if @controversy.support_1
      redirect_back(fallback_location: root_path,
                    alert: 'Você não pode pegar uma controvérsia de outro usuário do suporte')
    else
      @user = User.find(params[:user_id])
      if %w[admin call_center_user call_center_admin].include?(@user.role)
        @controversy.support_1 = @user
        if @controversy.save
          redirect_back(fallback_location: root_path,
                        notice: 'Agora essa controvérsia é sua')
        else
          redirect_back(fallback_location: root_path,
                        notice: 'Ocorreu um erro ao tentar pegar a controvérsia')
        end
      end
    end
  end

  # Configures the <tt>POST</tt> request to unlink
  # a <tt>support user</tt> to the Controversy
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/controversies/:id/unlink_controversy/:user_id</tt>
  def unlink_controversy
    authorize! :link, @controversy

    if @controversy.support_1 == User.find(params[:user_id])
      @controversy.support_1 = nil
      if @controversy.save
        redirect_back(fallback_location: root_path,
                      notice: 'Controvérsia liberada')
      else
        redirect_back(fallback_location: root_path,
                      notice: 'Ocorreu um erro ao tentar liberar a controvérsia')
      end
    else
      redirect_back(fallback_location: root_path,
                    alert: 'Essa controvérsia pertence a outro usuário do suporte')
    end
  end

  # Configures the <tt>POST</tt> request to link
  # a <tt>company user</tt> to the Controversy
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/controversies/:id/link_company_user/:user_id</tt>
  def link_company_user
    if !@controversy.company_user.nil?
      @controversy.company_user_id = nil
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário removido' : 'Erro na remoção de usuário')
    elsif @user.sei == @controversy.sei
      @controversy.company_user = @user
      ControversyMailer.user_added(@controversy.id, @user.id).deliver_later
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário adicionado' : 'Erro na adição de usuário')
    else
      redirect_to @controversy, alert: 'Usuário sem permissão para ser adicionado'
    end
  end

  # Configures the <tt>POST</tt> request to link
  # a <tt>city user</tt> to the Controversy
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/controversies/:id/link_city_user/:user_id</tt>
  def link_city_user
    if !@controversy.city_user.nil?
      @controversy.city_user_id = nil
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário removido' : 'Erro na remoção de usuário')
    elsif city_user_elegible?
      @controversy.city_user = @user
      ControversyMailer.user_added(@controversy.id, @user.id).deliver_later
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário adicionado' : 'Erro na adição de usuário')
    else
      redirect_to @controversy, alert: 'Usuário sem permissão para ser adicionado'
    end
  end

  # Configures the <tt>POST</tt> request to link
  # a <tt>unity user</tt> to the Controversy
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/controversies/:id/link_unity_user/:user_id</tt>
  def link_unity_user
    if !@controversy.unity_user.nil?
      @controversy.unity_user_id = nil
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário removido' : 'Erro na remoção de usuário')
    elsif unity_user_elegible?
      @controversy.unity_user = @user
      ControversyMailer.user_added(@controversy.id, @user.id).deliver_later
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário adicionado' : 'Erro na adição de usuário')
    else
      redirect_to @controversy, alert: 'Usuário sem permissão para ser adicionado'
    end
  end

  # Configures the <tt>POST</tt> request to link
  # a extra <tt>support user</tt> to the Controversy
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/controversias/controversies/:id/link_support_user/:user_id</tt>
  def link_support_user
    if !@controversy.support_2.nil?
      @controversy.support_2_user_id = nil
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário removido' : 'Erro na remoção de usuário')
    elsif support_like?(@user)
      @controversy.support_2 = @user
      ControversyMailer.user_added(@controversy.id, @user.id).deliver_later
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário adicionado' : 'Erro na adição de usuário')
    else
      redirect_to @controversy, alert: 'Usuário sem permissão para ser adicionado'
    end
  end

  private

  ####
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file
  ##

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
  # :section: Custom private methods
  ##

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def controversy_params
    params.require(:controversy).permit(:title, :description, :protocol, :closed_at, :sei,
                                        :contract_id, :city_id, :cnes, :company_user_id,
                                        :unity_user_id, :creator, :category, :complexity,
                                        :support_1_id, :support_2_id, :user_creator, :feedback,
                                        :files)
  end

  # Returns the Attachment instances's ids received in the
  # request, removing it from the parameters
  def retrieve_files(parameters)
    parameters.delete(:files).split(',') if parameters[:files]
  end

  # Returns the User creator received in the
  # request, removing it from the parameters
  def retrieve_user_creator(parameters)
    parameters.delete(:user_creator) if parameters[:user_creator]
  end

  # Returns a Call with the <tt>parameters</tt>
  # received in the request filled, as well as the
  # <tt>creator</tt>, <tt>creator_user_id</tt> and
  # <tt>support_1_user_id</tt> fields filled
  def create_controversy(parameters, user_creator_id)
    controversy = Controversy.new(parameters)
    controversy.creator ||= map_role_to_creator
    controversy[controversy.creator + '_user_id'] = user_creator_id || current_user.id
    controversy.support_1_user_id = current_user.id if support_user?
    controversy
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

  # Called by #create_controversy, this is a little mapping
  # to handle which field should be filled when relating
  # to the <tt>current_user</tt>
  def map_role_to_creator
    {
      company_user: 'company',
      company_admin: 'company',
      ubs_admin: 'unity',
      ubs_user: 'unity',
      city_admin: 'city',
      call_center_admin: 'support_1',
      call_center_user: 'support_1',
      admin: 'support_1'
    }[current_user.role.to_sym]
  end

  # For each Attachment instance id received in the
  # <tt>files</tt> parameter, creates the AttachmentLink
  # between the Controversy instance and the Attachment instance.
  def create_file_links(controversy, files)
    files.each do |file_uuid|
      @link = AttachmentLink.new(attachment_id: file_uuid, controversy_id: controversy.protocol,
                                 source: 'controversy')
      unless @link.save
        raise 'Não consegui criar o link entre arquivo e a Controvérsia.'\
              ' Por favor tente mais tarde'
      end
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
