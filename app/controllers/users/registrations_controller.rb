# frozen_string_literal: true

# Controller inherited from Devise::RegistrationsController,
# to handle locally the views for the Registration feature
# of Devise.
#
# <b>OBS.:</b> Our application only handle the
# <tt>update</tt> sanitizing action on this controller
class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  ##########################
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # Sanitizes the unwanted parameters when trying to update
  # a invitation
  # Makes the famous "Never trust parameters from internet,
  # only allow the white list through." on updates.
  #
  # It is called by a <tt>:before_action</tt> hook
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[name last_name cpf email
                                               current_password password password_confirmation system])
    begin
      params.require(:user)
            .require(%i[name last_name cpf email current_password])
    rescue StandardError
      redirect_back fallback_location: not_found_path, alert: 'Por favor, preencha todos os campos.'
    end
  end

  # Method thad overrides the path where the
  # <tt>current_user</tt> will be redirected after
  # first configuring his account details
  def after_sign_up_path_for(resource)
    signed_in_root_path(resource)
  end

  # Method thad overrides the path where the
  # <tt>current_user</tt> will be redirected after
  # updating his account details
  def after_update_path_for(resource)
    signed_in_root_path(resource)
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
