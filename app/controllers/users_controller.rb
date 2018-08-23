class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :global_user
  before_action :admin_only, :except => [:show, :pre_new_user_invitation]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    unless current_user.admin?
      unless @user == current_user
        redirect_to root_path, alert: 'Access denied.'
      end
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
    user = User.find(params[:id])
    user.destroy
    redirect_to users_path, notice: 'User deleted.'
  end

  def pre_new_user_invitation
    unless current_user.admin?
      redirect_to new_user_invitation_path
    end
  end

  def get_invitation_role
    $selected_role = params.require(:user).require(:role)
    redirect_to new_user_invitation_path
  end

  def global_user
    $current_user_role = current_user.role
    $current_user_sei = current_user.sei
  end

  private

  ### Functions to restrict user content
  def admin_only
    redirect_to root_path, alert: 'Access denied.' unless current_user.admin?
  end

  def city_admin_only
    unless current_user.city_admin?
      redirect_to root_path, alert: 'Access denied.'
    end
  end

  def city_user_only
    unless current_user.city_user?
      redirect_to root_path, alert: 'Access denied.'
    end
  end

  def ubs_admin_only
    unless current_user.ubs_admin?
      redirect_to root_path, alert: 'Access denied.'
    end
  end

  def ubs_user_only
    redirect_to root_path, alert: 'Access denied.' unless current_user.ubs_user?
  end

  def company_admin_only
    unless current_user.company_admin?
      redirect_to root_path, alert: 'Access denied.'
    end
  end

  def company_user_only
    unless current_user.company_user?
      redirect_to root_path, alert: 'Access denied.'
    end
  end

  def secure_params
    params.require(:user).permit(:role, :name, :cpf)
  end

end
