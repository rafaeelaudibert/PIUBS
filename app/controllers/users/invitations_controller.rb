class Users::InvitationsController < Devise::InvitationsController
  before_action :set_roles_allowed, only: :new
  before_action :set_unities_allowed, only: :new
  before_action :set_cities, only: :new
  before_action :set_companies, only: :new
  before_action :set_sei, only: :new
  before_action :set_cnes, only: :new
  before_action :set_city, only: :new
  before_action :update_sanitized_params, only: :update
  before_action :create_sanitized_params, only: :create

  def new
    @role = params[:role] if params[:role]
    @sei = params[:sei].to_i if params[:sei]
    super
  end

  def create
    super
  end

  def update
    super
  end

  private

  def set_roles_allowed
    if current_user.admin?
      $roles_allowed = %i[admin city_admin company_admin call_center_admin] ## disable :ubs_admin
    else
      if current_user.city_admin?
        $roles_allowed = [:ubs_admin]
      else
        if current_user.ubs_admin?
          $roless_allowed = [:ubs_user]
        else
          $roles_allowed = if current_user.company_admin?
                             [:company_user]
                           else
                             $roles_allowed = if current_user.call_center_admin?
                                                [:call_center_user]
                                              else
                                                []
                                              end
                           end
        end
      end
    end
  end

  def set_unities_allowed
    if current_user.city_admin?
      $unities_allowed = {}
      Unity.where(['city_id = ?', current_user.city_id]).each do |_unity|
        $unities_allowed[_unity.name] = _unity.cnes
      end
    end
  end

  def set_cities
    if current_user.admin?
      $cities = {}
      City.all.each do |_city|
        $cities[_city.name] = _city.id
      end
    end
  end

  def set_companies
    if current_user.admin?
      $companies = []
      Company.all.each do |_company|
        $companies << _company.sei
      end
    end
  end

  def set_sei
    $current_user_sei = current_user.sei if current_user.company_admin?
  end

  def set_cnes
    $current_user_cnes = current_user.cnes if current_user.ubs_admin?
  end

  def set_city
    $current_user_city = current_user.city_id if current_user.city_admin?
  end

  def update_sanitized_params
    devise_parameter_sanitizer.permit(:accept_invitation, keys: %i[name password password_confirmation invitation_token cpf])
    begin
      params.require(:user).require(:name)
      params.require(:user).require(:cpf)
    rescue StandardError
      redirect_back fallback_location: not_found_path, alert: 'Por favor, preencha todos os campos.'
    end
  end

  def create_sanitized_params
    devise_parameter_sanitizer.permit(:invite, keys: %i[email role sei cnes city_id])
  end
end
