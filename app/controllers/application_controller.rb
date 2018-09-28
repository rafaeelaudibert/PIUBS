# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ApplicationHelper

  def page_not_found
    redirect_to '/404.html'
  end

  def acess_denied
    redirect_to '/422.html'
  end
end
