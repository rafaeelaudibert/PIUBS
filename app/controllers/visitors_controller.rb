class VisitorsController < ApplicationController
  include ApplicationHelper

  def index
    if user_signed_in?
      redirect_to(calls_path)
    end
  end

  def welcome
    if user_signed_in?
      Rails.logger.info "message"
      index
    end
  end
end
