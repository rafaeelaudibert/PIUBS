# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :any_admin_only, only: %i[index]
  include ApplicationHelper

  def index
    @filterrific = initialize_filterrific(User,
                                          params[:filterrific],
                                          select_options: {
                                            sorted_by_name: User.all.options_for_sorted_by_name,
                                            with_role: User.all.options_for_with_role,
                                            with_status_adm: User.options_for_with_status_adm,
                                            with_status: User.all.options_for_with_status,
                                            with_state: State.all.map { |s| [s.name, s.id] },
                                            with_city: User.all.options_for_with_city,
                                            with_company: Company.all.map(&:sei)
                                          },
                                          persistence_id: false) || return

    if current_user.try(:admin?)
      @users = @filterrific.find.page(params[:page])
    elsif current_user.try(:call_center_admin?) ||
          current_user.try(:city_admin?) ||
          current_user.try(:company_admin?) ||
          current_user.try(:ubs_admin?)
      @users = @filterrific.find.where(invited_by_id: current_user.id).page(params[:page])
    end
  end

  def show
    @user = User.find(params[:id])
    unless current_user.id == @user.invited_by_id ||
           current_user.admin? ||
           @user == current_user
      redirect_to root_path, alert: 'Acesso Negado!'
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(secure_params)
      redirect_to users_path, notice: 'User updated.'
    else
      redirect_to users_path, alert: 'Unable to update user.'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to users_path, notice: 'User deleted.'
  end

  # RafaAudibert 5/10/18 - Removido para evitar erros do rubocop. Nao aparece em nenhum outro lugar
  # def get_invitation_role
  #   $selected_role = params.require(:user).require(:role)
  #   redirect_to new_user_invitation_path
  # end

  private

  ### Functions to restrict user content

  def any_admin_only
    unless current_user.admin? ||
           current_user.city_admin? ||
           current_user.company_admin? ||
           current_user.ubs_admin? ||
           current_user.call_center_admin?
      redirect_to root_path, alert: 'Acesso Negado!'
    end
  end

  def admin_only
    redirect_to root_path, alert: 'Acesso Negado!' unless current_user.admin?
  end

  def city_admin_only
    redirect_to root_path, alert: 'Acesso Negado!' unless current_user.city_admin?
  end

  def city_user_only
    redirect_to root_path, alert: 'Acesso Negado!' unless current_user.city_user?
  end

  def ubs_admin_only
    redirect_to root_path, alert: 'Acesso Negado!' unless current_user.ubs_admin?
  end

  def ubs_user_only
    redirect_to root_path, alert: 'Acesso Negado!' unless current_user.ubs_user?
  end

  def company_admin_only
    redirect_to root_path, alert: 'Acesso Negado!' unless current_user.company_admin?
  end

  def company_user_only
    redirect_to root_path, alert: 'Acesso Negado!' unless current_user.company_user?
  end

  def secure_params
    params.require(:user).permit(:role, :name, :cpf, :sei, :cnes, :city_id, :last_name)
  end
end
