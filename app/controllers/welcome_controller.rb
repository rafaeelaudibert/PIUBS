class WelcomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to(login_path) and return
    end
    render layout: 'welcome'
  end
end
