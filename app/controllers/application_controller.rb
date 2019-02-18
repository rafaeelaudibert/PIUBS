# frozen_string_literal: true

##
# Default controller from which all the other controllers will inherit
class ApplicationController < ActionController::Base
  include ApplicationHelper

  ##########################
  ## Hooks Configuration ###
  before_action :store_user_location!

  ###############################
  ## CanCan Exception Handling ##
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to denied_path, message: exception.message
  end

  ##########################
  # :section: Authentication methods
  # Method related to handle authentication errors

  # Raises a <tt>404 - Page not Found</tt> error
  def page_not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  # Raises a <tt>503 - Acess Denied</tt> error
  def acess_denied
    raise ActionController::RoutingError, 'Acess Denied'
  end

  # Raises a <tt>500 - Internal Server Error</tt> error
  def internal_error
    raise ActionController::RoutingError, 'Internal Server Error'
  end

  private

  # Stores the location which the <tt>current_user</tt> wants to access,
  # in case we need to make a redirect after a login
  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath) if storable_location?
  end

  # Called by the #store_user_location! method, to verify if we should
  # store this user location
  #
  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as
  #    that could cause an infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  # - The request will create an infinite loop
  def storable_location?
    request.get? && is_navigational_format? &&
      !devise_controller? && !request.xhr? &&
      non_infinite_loop?
  end

  # Called by the method #storable_location?, returns a boolean informing if we would be
  # redirecting to a link which would cause a loop, as it would try to log in the user again
  def non_infinite_loop?
    request.fullpath != '/' && request.fullpath != '/user/sign_in'
  end

  protected

  ##########################
  # :section: Protected methods

  # Returns which path should the user go after log in
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || user_path(current_user.id)
  end

  # Overwriting the sign_out redirect path method, to redirect the user to '/'
  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end
end
