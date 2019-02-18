# frozen_string_literal: true

##
# This is the default helper to the Application
module ApplicationHelper
  ##########################
  # :section: Devise methods
  # Methods created and used by Devise Gem

  # Devise method with the name of the model which
  # handles its resource
  #
  # In this app, we only have one resource which is the User
  def resource_name
    :user
  end

  # Devise method to handle its resource which
  # is a User instance
  def resource
    @resource ||= User.new
  end

  # Devise method
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  ##########################
  # :section: Custom helper methods

  # Method to generate a recursive view layout
  def inside_layout(parent_layout, params)
    view_flow.set :layout, (capture { yield })
    render "layouts/#{parent_layout}", params: params
  end

  # User helper to verify if a user has the <tt>admin</tt> role
  #
  # By default, if no parameters are passed, it checks
  # the <tt>current_user</tt>
  def admin?(user = current_user)
    user.try(:admin?)
  end

  # User helper to verify if a user has some kind
  # of admin rights. This is, it checks if the user has
  # the following roles: <tt>admin</tt>, <tt>ubs_admin</tt>,
  # <tt>company_admin</tt>, <tt>call_center_admin</tt>
  # or <tt>city_admin</tt>
  #
  # By default, if no parameters are passed, it checks
  # the <tt>current_user</tt>
  def admin_like?(user = current_user)
    user.try(:admin?) || user.try(:ubs_admin?) ||
      user.try(:company_admin?) || user.try(:call_center_admin?) ||
      user.try(:city_admin?)
  end

  # User helper to verify if a user has some kind
  # the rights to access call_center pages.
  # This is, it checks if the user has
  # the following roles: <tt>admin</tt>, <tt>call_center_user</tt>,
  # or <tt>call_center_admin</tt>
  #
  # By default, if no parameters are passed, it checks
  # the <tt>current_user</tt>
  def support_like?(user = current_user)
    user.try(:admin?) || user.try(:call_center_user?) ||
      user.try(:call_center_admin?)
  end

  # User helper to verify if a user has <tt>ubs_admin</tt>
  # or <tt>ubs_user</tt> roles
  #
  # By default, if no parameters are passed, it checks
  # the <tt>current_user</tt>
  def ubs_user?(user = current_user)
    user.try(:ubs_admin?) || user.try(:ubs_user?)
  end

  # User helper to verify if a user has <tt>company_user</tt>
  # or <tt>company_admin</tt> roles
  #
  # By default, if no parameters are passed, it checks
  # the <tt>current_user</tt>
  def company_user?(user = current_user)
    user.try(:company_user?) || user.try(:company_admin?)
  end

  # User helper to verify if a user has <tt>call_center_user</tt>
  # or <tt>call_center_admin</tt> roles
  #
  # By default, if no parameters are passed, it checks
  # the <tt>current_user</tt>
  def support_user?(user = current_user)
    user.try(:call_center_user?) || user.try(:call_center_admin?)
  end

  # User helper to verify if a user has the <tt>city_admin</tt> role
  #
  # By default, if no parameters are passed, it checks
  # the <tt>current_user</tt>
  def city_user?(user = current_user)
    user.try(:city_admin?)
  end

  # User helper to verify if a user has the <tt>faq_inserter</tt> role
  #
  # By default, if no parameters are passed, it checks
  # the <tt>current_user</tt>
  def faq_inserter?(user = current_user)
    user.try(:faq_inserter?)
  end

  # Filterrific method
  #
  # Default filterrific query, which searches the database
  # according to its initial configuration
  def filterrific_query
    @filterrific.find.page(params[:page])
  end
end
