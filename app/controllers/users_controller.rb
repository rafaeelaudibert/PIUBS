# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_like?, only: %i[index]
  include ApplicationHelper

  def index
    @filterrific = initialize_filterrific(User,
                                          params[:filterrific],
                                          select_options: create_options_for_filterrific,
                                          persistence_id: false) || return

    @users = allowed_users
  end

  def show
    @user = User.find(params[:id])
    unless current_user.id == @user.invited_by_id ||
           current_user.admin? ||
           @user == current_user
      redirect_to root_path, alert: 'Acesso Negado!'
    end
    @company = Company.find(@user.sei) if @user.sei
    @unity = Unity.find(@user.cnes) if @user.cnes
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

  private

  def create_options_for_filterrific
    {
      sorted_by_name: User.all.options_for_sorted_by_name,
      with_role: User.all.options_for_with_role,
      with_status_adm: User.options_for_with_status_adm,
      with_status: User.all.options_for_with_status,
      with_state: State.all.map { |s| [s.name, s.id] },
      with_city: User.all.options_for_with_city,
      with_company: Company.all.map(&:sei)
    }
  end

  def allowed_users
    if admin?
      @filterrific.find.page(params[:page]).limit(999999)
    elsif admin_like?
      @filterrific.find.where(invited_by_id: current_user.id).page(params[:page]).limit(999999)
    end
  end

  def secure_params
    params.require(:user).permit(:role, :name, :cpf, :sei, :cnes, :city_id, :last_name)
  end
end
