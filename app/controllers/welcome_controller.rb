class WelcomeController < ApplicationController
  def index
    if user_signed_in?
      VisitorsController.index
    end
  end
end
