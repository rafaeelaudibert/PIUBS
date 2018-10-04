# frozen_string_literal: true

class VisitorsController < ApplicationController
  include ApplicationHelper
  def index
    if user_signed_in?
      redirect_to(calls_path)
    end
  end
end
