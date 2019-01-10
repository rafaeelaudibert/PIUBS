# frozen_string_literal: true

##
# This is a generic controller, to handle the view when
# no User instance is logged in
class WelcomeController < ApplicationController
  ####
  # :section: View methods
  # Method related to generating views
  ##

  # Configures the <tt>index</tt> page. If the user is already
  # logged in, redirects the user to the logged in dashboard
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/</tt>
  def index
    redirect_to(new_user_session_path) && return if user_signed_in?
    render layout: 'welcome'
  end
end
