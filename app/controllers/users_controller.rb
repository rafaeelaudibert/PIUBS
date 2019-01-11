# frozen_string_literal: true

##
# This is the controller for the User model
#
# It is responsible for handling the views for any USer
class UsersController < ApplicationController
  include ApplicationHelper

  # Hooks Configuration
  before_action :authenticate_user!
  before_action :admin_like?, only: %i[index]
  before_action :set_user, only: %i[show destroy update_system update_role]

  # Autocomplete Configuration
  autocomplete :user, :company
  autocomplete :user, :city
  autocomplete :user, :unity
  autocomplete :user, :support

  ####
  # :section: View methods
  # Method related to generating views
  ##

  # Configures the <tt>index</tt> page for the USer model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/users</tt>
  # [GET] <tt>/users.json</tt>
  def index
    @filterrific = initialize_filterrific(User,
                                          params[:filterrific],
                                          select_options: create_options_for_filterrific,
                                          persistence_id: false) || return

    @users = allowed_users.page(params[:page])
  end

  # Configures the <tt>show</tt> page for the USer model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/users/:id</tt>
  # [GET] <tt>/users/:id.json</tt>
  def show
    unless current_user.id == @user.invited_by_id ||
           current_user.admin? ||
           @user == current_user
      redirect_to root_path, alert: 'Acesso Negado!'
    end

    generate_user_info
  end

  # Configures the <tt>DELETE</tt> request to delete a User
  #
  # <b>ROUTES</b>
  #
  # [DELETE] <tt>/users/:id</tt>
  def destroy
    @user.destroy
    redirect_to users_path, notice: 'Usuário apagado.'
  end

  # Configures the <tt>autocomplete</tt> request asking for
  # the company users.
  # It returns all User instances which are children of the
  # queried Company, parsed in the right format
  #
  # <b>OBS.:</b> This view only exist in a JSON format
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/users/autocomplete_company_users.json</tt>
  def autocomplete_company_users
    terms = params[:term]
    sei = params[:sei]
    @users = User.from_company(sei).find_by_term(terms)
  end

  # Configures the <tt>autocomplete</tt> request asking for
  # the city users.
  # It returns all User instances which are children of the
  # queried City, parsed in the right format
  #
  # <b>OBS.:</b> This view only exist in a JSON format
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/users/autocomplete_city_users.json</tt>
  def autocomplete_city_users
    terms = params[:term]
    id = params[:city_id]
    @users = User.from_city(id).find_by_term(terms)
  end

  # Configures the <tt>autocomplete</tt> request asking for
  # the unity users.
  # It returns all User instances which are children of the
  # queried Unity, parsed in the right format
  #
  # <b>OBS.:</b> This view only exist in a JSON format
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/users/autocomplete_unity_users.json</tt>
  def autocomplete_unity_users
    terms = params[:term]
    cnes = params[:cnes]
    @users = User.from_ubs(cnes).find_by_term(terms)
  end

  # Configures the <tt>autocomplete</tt> request asking for
  # the unity users.
  # It returns all User instances which are children of the
  # queried Unity, parsed in the right format
  #
  # <b>OBS.:</b> This view only exist in a JSON format
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/users/autocomplete_support_users.json</tt>
  def autocomplete_support_users
    terms = params[:term]
    self_id = params[:user_id]
    @users = User.except(self_id)
                 .support_accounts
                 .find_by_term(terms)
  end

  # Configures the <tt>update_system</tt> request asking to
  # change a User instance <tt>system</tt> field
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/users/update_role</tt>
  def update_system
    authorize! :update_user_system, @user

    if params[:user][:system] != ''
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

  # Configures the <tt>update_system</tt> request asking to
  # change a User instance <tt>system</tt> field
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/users/update_role</tt>
  def update_role
    authorize! :update_user_role, @user

    if params[:user][:role] != ''
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

  ####
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file
  ##

  # Configures the User instance when called by
  # the <tt>:before_action</tt> hook
  def set_user
    @user = User.find(params[:id])
  end

  ####
  # :section: Filterrific methods
  # Method related to the Filterrific Gem
  ##

  # Filterrific method
  #
  # Configures the basic options for the
  # <tt>Filterrific</tt> queries
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

  ####
  # :section: Custom private methods
  ##

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def secure_params
    params.require(:user).permit(:role, :name, :cpf, :sei, :cnes, :city_id, :last_name,
                                 :password, :current_password, :password_confirmation)
  end

  # Method called by #index to verify the users which this user can see in the <tt>/users</tt> page
  def allowed_users
    if admin?
      @filterrific.find.page(params[:page]).limit(999_999)
    elsif admin_like?
      @filterrific.find.invited_by(current_user.id).page(params[:page]).limit(999_999)
    end
  end

  # Method called by the #index view handler,
  # to generate all the current user info
  def generate_user_info
    @company = Company.find(@user.sei) if @user.sei
    @unity = Unity.find(@user.cnes) if @user.cnes
    @city = City.find(@user.city_id) if @user.city_id
    @state = State.find(@city.state_id) if @city
  end

  ####
  # :section: CanCanCan methods
  # Methods which are related to the CanCanCan gem
  ##

  # CanCanCan Method
  #
  # Default CanCanCan Method, declaring the UserAbility
  def current_ability
    @current_ability ||= UserAbility.new(current_user)
  end
end
