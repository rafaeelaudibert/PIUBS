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
    sign_in_url = new_user_session_url
    if request.referer == sign_in_url
      super
    else
      stored_location_for(resource) || request.referer || root_path
    end
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end
end
