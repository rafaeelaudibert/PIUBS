# frozen_string_literal: true

class ControversiesController < ApplicationController
  before_action :authenticate_user!
  before_action :restrict_system!
  before_action :set_controversy, except: %i[index new create]
  before_action :set_user, only: %i[company_user city_user support_user unity_user]
  before_action :authorize_alter_user, only: %i[company_user city_user unity_user support_user]

  # GET /controversies
  # GET /controversies.json
  def index
    (@filterrific = initialize_filterrific(Controversy, params[:filterrific],
      select_options: options_for_filterrific,
      persistence_id: false)) || return
    @controversies = filtered_controversies

    authorize! :index, Controversy
  end





  # GET /controversies/1
  # GET /controversies/1.json
  def show
    @reply = Reply.new
    @feedback = Feedback.new
    @user_creator = begin
                      User.find(@controversy[@controversy.creator + '_user_id']).name
                    rescue StandardError
                      'Sem usuário criador (Relate ao suporte)'
                    end
    authorize! :show, @controversy
  end

  # GET /controversies/new
  def new
    @controversy = Controversy.new
    authorize! :new, @controversy

    # rubocop:disable Style/GuardClause
    if (city_user? || ubs_user?) && current_user.city.contract_id.nil?
      redirect_back(fallback_location: controversies_path,
                    notice: 'A sua cidade não possui contratos')
    end
    # rubocop:enable Style/GuardClause
  end

  # POST /controversies
  # POST /controversies.json
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

  # POST calls/link_controversy
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

  # POST calls/unlink_controversy
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

  # POST /:id/company_user/:user_id
  def company_user
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

  # POST /:id/city_user/:user_id
  def city_user
    if !@controversy.city_user.nil?
      @controversy.city_user_id = nil
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário removido' : 'Erro na remoção de usuário')
    elsif city_user_eligible?
      @controversy.city_user = @user
      ControversyMailer.user_added(@controversy.id, @user.id).deliver_later
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário adicionado' : 'Erro na adição de usuário')
    else
      redirect_to @controversy, alert: 'Usuário sem permissão para ser adicionado'
    end
  end

  # POST /:id/unity_user/:user_id
  def unity_user
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

  # POST /:id/support_user/:user_id
  def support_user
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
  # :section: Filterrific methods
  # Method related to the Filterrific Gem
  ##

  # Filterrific method
  #
  # Configures the basic options for the
  # <tt>Filterrific</tt> queries
  def options_for_filterrific
    {
      sorted_by_creation: Controversy.options_for_sorted_by_creation,
      with_status: Controversy.options_for_with_status,
      with_state: retrieve_states_for_filterrific,
      with_city: [],
      with_ubs: [],
      with_company: Company.all.map(&:sei)
    }
  end

  # Filterrific method
  #
  # Configures the State instances which can be
  # used to sort the Controversy instances
  def retrieve_states_for_filterrific
    if current_user.cnes
      State.find(current_user.company
        .contracts
        .map { |c| c.city.state_id }).map { |s| [s.name, s.id] }
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
  def controversies_from_support_user
    filterrific_query.from_support_user [current_user.id, nil]
  end

  # Filterrific method
  #
  # Returns all the Controversies instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>support_admin</tt> role,
  # which is handled by the calling function
  def controversies_from_support_admin
    filterrific_query.from_support_user [User.where(invited_by_id: current_user.id).map(&:id),
                                         current_user.id,
                                         nil].flatten
  end

  def controversies_for_company_admin
    filterrific_query.from_company current_user.sei
  end

  def controversies_for_company_user
    filterrific_query.from_company_user current_user.id
  end

  def controversies_for_ubs_admin
    filterrific_query.from_ubs_admin current_user.cnes
  end

  def controversies_for_ubs_user
    filterrific_query.from_ubs_user current_user.id
  end

  def controversies_for_city_user
    filterrific_query.from_city_user current_user.id
  end

  def controversies_for_admin
    filterrific_query
  end

  def filtered_controversies
    if support_user?
      current_user.call_center_user? ? controversies_from_support_user : controversies_from_support_admin
    elsif admin?
      controversies_for_admin
    else
      linked_users?
    end
  end

  def linked_users?
    if company_user?
      current_user.company_admin? ? controversies_for_company_admin : controversies_for_company_user
    elsif ubs_user?
      current_user.ubs_admin? ? controversies_for_ubs_admin : controversies_for_ubs_user
    elsif city_user?
      controversies_for_city_user
    else
      []
    end
  end

  ####

  # Use callbacks to share common setup or constraints between actions.
  def set_controversy
    @controversy = Controversy.find(params[:id])
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def retrieve_files(parameters)
    parameters.delete(:files).split(',') if parameters[:files]
  end

  def retrieve_user_creator(parameters)
    puts parameters
    parameters.delete(:user_creator) if parameters[:user_creator]
  end

  def create_controversy(parameters, user_creator_id)
    controversy = Controversy.new(parameters)
    controversy.contract_id = controversy.city.contract.id
    controversy.creator ||= map_role_to_creator
    controversy[controversy.creator + '_user_id'] = user_creator_id || current_user.id
    controversy.support_1_user_id = current_user.id if support_user?
    controversy
  end

  def city_user_elegible?
    @user.city_id == @controversy.city_id && @user.cnes.nil?
  end

  def unity_user_elegible?
    (@controversy.cnes.nil? && @user.city_id == @controversy.city_id) ||
      @user.cnes == @controversy.cnes
  end

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

  # Never trust parameters from the scary internet, only allow the white list through.
  def controversy_params
    params.require(:controversy).permit(:title, :description, :protocol, :closed_at, :sei,
                                        :contract_id, :city_id, :cnes, :company_user_id,
                                        :unity_user_id, :creator, :category, :complexity,
                                        :support_1_id, :support_2_id, :user_creator, :feedback,
                                        :files)
  end

  def restrict_system!
    redirect_to denied_path unless current_user.both? || current_user.controversies?
  end

  def authorize_alter_user
    authorize! :alter_user, @controversy
  end

  def current_ability
    @current_ability ||= ControversyAbility.new(current_user)
  end
end
