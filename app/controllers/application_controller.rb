# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ApplicationHelper
  before_action :store_user_location!

  def page_not_found
    redirect_to '/404.html'
  end

  def acess_denied
    redirect_to '/422.html'
  end

  private

  def infinite_loop
    request.fullpath != '/' && request.fullpath != '/user/sign_in'
  end

  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as
  #    that could cause an infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  # - The request will create an infinite loop
  def storable_location?
    request.get? && is_navigational_format? &&
      !devise_controller? && !request.xhr? &&
      !infinite_loop?
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath) if storable_location?
  end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || user_path(current_user.id)
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end
end
