# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_like?, only: %i[index]
  autocomplete :user, :company
  autocomplete :user, :city
  autocomplete :user, :unity
  autocomplete :user, :support
  include ApplicationHelper

  def index
    @filterrific = initialize_filterrific(User,
                                          params[:filterrific],
                                          select_options: create_options_for_filterrific,
                                          persistence_id: false) || return

    @users = allowed_users.page(params[:page])
  end

  def show
    @user = User.find(params[:id])
    
    unless current_user.id == @user.invited_by_id ||
           current_user.admin? ||
           @user == current_user
      redirect_to root_path, alert: 'Acesso Negado!'
    end

    generate_user_info
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
    redirect_to users_path, notice: 'Usuário apagado.'
  end

  def autocomplete_company_users
    terms = params[:term]
    company_users = User.where(role: %i[company_admin company_user], sei: params[:sei])
    render json: company_users.where('name ILIKE ? OR cpf ILIKE ?', "%#{terms}%", "%#{terms}%")
                              .map { |user|
                                { id: user.id,
                                  company_user_id: user.id,
                                  label: "#{user.name} - #{user.cpf}",
                                  value: user.name }
                              }
  end

  def autocomplete_city_users
    terms = params[:term]
    city_users = User.where(role: :city_admin, city_id: params[:city_id], cnes: '')
    render json: city_users.where('name ILIKE ? OR cpf ILIKE ?', "%#{terms}%", "%#{terms}%")
                           .map { |user|
                             { id: user.id,
                               city_user_id: user.id,
                               label: "#{user.name} - #{user.cpf}",
                               value: user.name }
                           }
  end

  def autocomplete_unity_users
    terms = params[:term]
    unity_user = User.where(role: %i[ubs_admin ubs_user], cnes: JSON.parse(params[:cnes]))
    render json: unity_user.where('name ILIKE ? OR cpf ILIKE ?', "%#{terms}%", "%#{terms}%")
                           .map { |user|
                             { id: user.id,
                               unity_user_id: user.id,
                               label: "#{user.name} - #{user.cpf}",
                               value: user.name }
                           }
  end

  def autocomplete_support_users
    terms = params[:term]
    support_users = User.where(role: %i[call_center_admin call_center_user])
                        .where.not(id: params[:user_id])
    render json: support_users.where('name ILIKE ? OR cpf ILIKE ?', "%#{terms}%", "%#{terms}%")
                              .map { |user|
                                { id: user.id,
                                  support_user_id: user.id,
                                  label: "#{user.name} - #{user.cpf}",
                                  value: user.name }
                              }
  end

  def update_system
    @user = User.find(params[:user_id])
    authorize! :update_user_system, @user

    if params[:user][:system] != ""
      @user.system = params[:user][:system].to_i

      if @user.save
        redirect_back(fallback_location: root_path,
                      notice: 'Dados do usuário atualizados com sucesso')
      else
        redirect_back(fallback_location: root_path,
          alert: 'Ocorreu um erro ao tentar atualizar os dados do usuário')
      end
    else
      redirect_back(fallback_location: root_path,
        alert: 'Selecione ao menos um sistema')
    end
  end

  def update_role
    @user = User.find(params[:user_id])
    authorize! :update_user_role, @user

    if params[:user][:role] != ""
      @user.role = params[:user][:role].to_i if params[:user][:role]

      if @user.save
        redirect_back(fallback_location: root_path,
                      notice: 'Dados do usuário atualizados com sucesso')
      else
        redirect_back(fallback_location: root_path,
          alert: 'Ocorreu um erro ao tentar atualizar os dados do usuário')
      end
    else
      redirect_back(fallback_location: root_path,
        alert: 'Selecione ao menos um perfil de acesso')
    end
  end

  private

  def generate_user_info
    @company = Company.find(@user.sei) if @user.sei
    @unity = Unity.find(@user.cnes) if @user.cnes
    @city = City.find(@user.city_id) if @user.city_id
    @state = State.find(@city.state_id) if @city
  end

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
      @filterrific.find.page(params[:page]).limit(999_999)
    elsif admin_like?
      @filterrific.find.where(invited_by_id: current_user.id).page(params[:page]).limit(999_999)
    end
  end

  def secure_params
    params.require(:user).permit(:role, :name, :cpf, :sei, :cnes, :city_id, :last_name, :password, :current_password, :password_confirmation)
  end

  def current_ability
    @current_ability ||= UserAbility.new(current_user)
  end
end
