class RegistrationsController < Devise::RegistrationsController
  before_action :admin_only
  skip_before_action :require_no_authentication, only: [:new]
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

def sign_up_params
  params.require(:user).permit(:name, :role, :sei ,:email, :password, :password_confirmation)
end

def account_update_params
  params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
end

def admin_only
  unless current_user.try(:admin?)
    redirect_to not_found_path
  end
end

end
