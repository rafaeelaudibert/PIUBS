# frozen_string_literal: true

class WelcomeController < ApplicationController
  def index
    redirect_to(login_path) && return if user_signed_in?
    render layout: 'welcome'
  end
end
