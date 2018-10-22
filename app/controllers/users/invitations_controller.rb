# frozen_string_literal: true

class Users::InvitationsController < Devise::InvitationsController
  before_action :admin_only, only: :new
  before_action :set_roles_allowed, only: :new
  before_action :update_sanitized_params, only: :update
  before_action :create_sanitized_params, only: :create

  def new
    @role = params[:role] || $roles_allowed[0] if $roles_allowed.length == 1
    @sei = params[:sei].to_i if params[:sei]
    @city_id = params[:city_id].to_i if params[:city_id]
    super
  end

  def create
    params[:user][:cnes] = '' if params[:user] && !%w[ubs_admin ubs_user].include?(params[:user][:role])
    params[:user][:city_id] = '' if params[:user] && params[:user][:city_id] == '0'
    params[:user][:state_id] = '' if params[:user] && params[:user][:state_id] == '0'
    super
  end

  def update
    super
  end

  protected

  def after_invite_path_for(resource_name)
    users_path(resource_name)
  end

  private

  def set_roles_allowed
    $roles_allowed = if current_user.admin?
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

  def update_sanitized_params
    devise_parameter_sanitizer.permit(:accept_invitation,
                                      keys: %i[name last_name password
                                               password_confirmation invitation_token cpf])
    begin
      params.require(:user).require(:name)
      params.require(:user).require(:last_name)
      params.require(:user).require(:cpf)
    rescue StandardError
      redirect_back fallback_location: not_found_path,
                    alert: 'Por favor, preencha todos os campos.'
    end
  end

  def create_sanitized_params
    devise_parameter_sanitizer.permit(:invite, keys: %i[email role sei cnes city_id])
  end

  def admin_only
    unless current_user.admin? ||
           current_user.ubs_admin? ||
           current_user.company_admin? ||
           current_user.call_center_admin? ||
           current_user.city_admin?
      redirect_to root_path, alert: 'Acesso negado.'
    end
  end
end
