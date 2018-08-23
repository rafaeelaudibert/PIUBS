class Users::InvitationsController < Devise::InvitationsController
  # before_action :configure_permitted_parameters

  def new
    super
  end

  def create
    super
  end

  # private

  # def secure_params
  #   params.require(:user).permit(:name)
  # end

  # def configure_permitted_parameters
  #   devise_parameter_sanitizer.for(:accept_invitation) << [:location_id]
  #   devise_parameter_sanitizer.for(:invite) << [:location_id]
  # end

end
