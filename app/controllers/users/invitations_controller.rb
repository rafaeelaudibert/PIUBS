# frozen_string_literal: true

# Controller inherited from Devise::InvitationsController,
# to handle locally the views for the Invitation feature
# of Devise.
class Users::InvitationsController < Devise::InvitationsController
  ##########################
  ## Hooks Configuration ###
  before_action :admin_only, only: :new
  before_action :update_sanitized_params, only: :update
  before_action :create_sanitized_params, only: :create
  before_action :set_roles_allowed, only: %i[new create]

  ##########################
  # :section: View methods
  # Method related to generating views

  # Configures the <tt>new</tt> page used to invite
  # new User instances
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>//users/invitation/new</tt>
  def new
    @role = params[:role] || (@roles_allowed[0] if @roles_allowed.length == 1)
    @sei = params[:sei].to_i if params[:sei]
    @city_id = params[:city_id].to_i if params[:city_id]
    super
  end

  # Configures the <tt>POST</tt> request to create a new User
  # through the invitation method
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/users/invitation</tt>
  def create
    sanitize_optional_params if params[:user]
    super
  end

  private

  ##########################
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file

  # Configures which roles the <tt>current_user</tt>,
  # which is trying to invite a new User, can invite
  # it for.
  #
  # It is called by a <tt>:before_action</tt> hook
  def set_roles_allowed
    @roles_allowed = if current_user.admin?
                       %i[faq_inserter admin city_admin ubs_admin company_admin call_center_admin]
                     elsif current_user.city_admin?
                       [:ubs_admin]
                     elsif current_user.ubs_admin?
                       [:ubs_user]
                     elsif current_user.company_admin?
                       [:company_user]
                     elsif current_user.call_center_admin?
                       [:call_center_user]
                     else
                       []
                     end
  end

  # Verifies that the User instance trying to access this
  # controllers, has a role of the <tt>admin_like</tt> type.
  #
  # It is called by a <tt>:before_action</tt> hook
  def admin_only
    unless current_user.admin? ||
           current_user.ubs_admin? ||
           current_user.company_admin? ||
           current_user.call_center_admin? ||
           current_user.city_admin?
      redirect_to root_path, alert: 'Acesso negado.'
    end
  end

  # Sanitizes the unwanted parameters when trying to update
  # a invitation
  # Makes the famous "Never trust parameters from internet,
  # only allow the white list through." on updates.
  #
  # It is called by a <tt>:before_action</tt> hook
  def update_sanitized_params
    devise_parameter_sanitizer.permit(:accept_invitation,
                                      keys: %i[name last_name password
                                               password_confirmation invitation_token cpf])
    begin
      params.require(:user).require(%i[name last_name cpf])
    rescue StandardError
      redirect_back fallback_location: not_found_path,
                    alert: 'Por favor, preencha todos os campos.'
    end
  end

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  #
  # It is called by a <tt>:before_action</tt> hook
  def create_sanitized_params
    devise_parameter_sanitizer.permit(:invite, keys: %i[email role sei cnes city_id system])
  end

  ##########################
  # :section: Custom private methods

  # Method that sanitizes the optional parameters to
  # prevent errors when inserting a new User in the DB
  #
  # It is called by the #create method
  def sanitize_optional_params
    params[:user][:cnes] = sanitize_cnes
    params[:user][:city_id] = sanitize_city_id
    params[:user][:state_id] = sanitize_state_id
    params[:user][:sei] = sanitize_sei
    params[:user][:system] = sanitize_system
  end

  # Method called by #sanitize_optional_params
  # that sanitizes the <tt>system</tt> parameter to prevent
  # City and Unity instance users to have access to the
  # Apoio as Empresas system
  def sanitize_system
    %w[admin call_center_user call_center_admin company_admin company_user].include?(params[:user][:role]) ? params[:user][:system] : 1
  end

  # Method called by #sanitize_optional_params
  # that sanitizes the <tt>cnes</tt> parameter to prevent
  # User instances who doesn't belong to a Unity to have their
  # <tt>cnes</tt> field filled.
  def sanitize_cnes
    %w[ubs_admin ubs_user].include?(params[:user][:role]) ? params[:user][:cnes] : ''
  end

  # Method called by #sanitize_optional_params
  # that sanitizes the <tt>city_id</tt> parameter to prevent
  # User instances who doesn't belong to a City to have their
  # <tt>city_id</tt> field filled.
  def sanitize_city_id
    return '' if params[:user][:city_id] == '0' ||
                 !%w[city_admin ubs_admin ubs_user].include?(params[:user][:role])

    params[:user][:city_id]
  end

  # Method called by #sanitize_optional_params
  # that sanitizes the <tt>state_id</tt> parameter to prevent
  # User instances who doesn't belong to a City,
  # consequently a State, to have their
  # <tt>state_id</tt> field filled.
  def sanitize_state_id
    return '' if params[:user][:state_id] == '0' ||
                 !%w[city_admin ubs_admin ubs_user].include?(params[:user][:role])

    params[:user][:state_id]
  end

  # Method called by #sanitize_optional_params
  # that sanitizes the <tt>sei</tt> parameter to prevent
  # User instances who doesn't belong to a Company to have their
  # <tt>sei</tt> field filled.
  def sanitize_sei
    return '' if params[:user][:sei] == '0' ||
                 !%w[company_admin company_user].include?(params[:user][:role])

    params[:user][:sei]
  end

  protected

  # Configures the path where the User instance creating
  # the new User will be redirected to
  def after_invite_path_for(resource_name)
    users_path(resource_name)
  end
end
