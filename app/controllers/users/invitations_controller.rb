class Users::InvitationsController < Devise::InvitationsController
  before_action :set_roles_allowed, :only => :new
  before_action :set_unities_allowed, :only => :new
  before_action :set_cities, :only => :new
  before_action :set_companies, :only => :new
  before_action :set_sei, :only => :new
  before_action :set_cnes, :only => :new
  before_action :set_city, :only => :new
  before_action :update_sanitized_params, :only => :update
  before_action :create_sanitized_params, :only => :create

  def new
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
      $roles_allowed = [:admin, :city_admin, :company_admin, :call_center_admin] ## disable :ubs_admin
    else
      if current_user.city_admin?
        $roles_allowed = [:ubs_admin]
      else
        if current_user.ubs_admin?
          $roless_allowed = [:ubs_user]
        else
          if current_user.company_admin?
            $roles_allowed = [:company_user]
          else
            if current_user.call_center_admin?
              $roles_allowed = [:call_center_user]
            else
              $roles_allowed = []
            end
          end
        end
      end
    end
  end

  def set_unities_allowed
    if current_user.city_admin?
      $unities_allowed = Hash.new
      Unity.where(["city_id = ?", current_user.city_id]).each do |_unity|
        $unities_allowed[_unity.name] = _unity.cnes
      end
    end
  end

  def set_cities
    if current_user.admin?
      $cities = Hash.new
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
    if current_user.company_admin?
      $current_user_sei = current_user.sei
    end
  end

  def set_cnes
    if current_user.ubs_admin?
      $current_user_cnes = current_user.cnes
    end
  end

  def set_city
    if current_user.city_admin?
      $current_user_city = current_user.city_id
    end
  end

  def update_sanitized_params
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:name, :password, :password_confirmation, :invitation_token, :cpf])
  end

  def create_sanitized_params
    devise_parameter_sanitizer.permit(:invite, keys: [:email, :role, :sei, :cnes, :city_id])
  end

end
