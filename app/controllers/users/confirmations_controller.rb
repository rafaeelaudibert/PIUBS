# frozen_string_literal: true

# User module used by Devise Gem to handle all this
# application authentication
module Users
  # Controller inherited from Devise::ConfirmationsController,
  # to handle locally the views for the Confirmation feature
  # of Devise.
  #
  # <b>OBS.:</b> This feature is not used in our application
  class ConfirmationsController < Devise::ConfirmationsController
    # GET /resource/confirmation/new
    # def new
    #   super
    # end

    # POST /resource/confirmation
    # def create
    #   super
    # end

    # GET /resource/confirmation?confirmation_token=abcdef
    # def show
    #   super
    # end

    # protected

    # The path used after resending confirmation instructions.
    # def after_resending_confirmation_instructions_path_for(resource_name)
    #   super(resource_name)
    # end

    # The path used after confirmation.
    # def after_confirmation_path_for(resource_name, resource)
    #   super(resource_name, resource)
    # end
  end
end
