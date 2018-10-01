# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ApplicationHelper

  def page_not_found
    redirect_to '/404.html'
  end

  def acess_denied
    redirect_to '/422.html'
  end

  protected
  def after_sign_in_path_for(resource)
    calls_path || stored_location_for(resource) || root_path
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    login_path
  end

end
