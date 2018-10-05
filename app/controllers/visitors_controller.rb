# frozen_string_literal: true

class VisitorsController < ApplicationController
  include ApplicationHelper
  def index
    redirect_to(calls_path) if user_signed_in?
  end
end
