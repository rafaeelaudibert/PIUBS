# frozen_string_literal: true

module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def inside_layout(parent_layout, params)
    view_flow.set :layout, (capture { yield })
    render "layouts/#{parent_layout}", params: params
  end

  # User helper
  def admin?(user = current_user)
    user.try(:admin?)
  end

  def admin_like?(user = current_user)
    user.try(:admin?) || user.try(:ubs_admin?) ||
      user.try(:company_admin?) || user.try(:call_center_admin?) ||
      user.try(:city_admin?)
  end

  def support_like?(user = current_user)
    user.try(:admin?) || user.try(:call_center_user?) ||
      user.try(:call_center_admin?)
  end

  def ubs_user?(user = current_user)
    user.try(:ubs_admin?) || user.try(:ubs_user?)
  end

  def company_user?(user = current_user)
    user.try(:company_user?) || user.try(:company_admin?)
  end

  def support_user?(user = current_user)
    user.try(:call_center_user?) || user.try(:call_center_admin?)
  end

  def city_user?(user = current_user)
    user.try(:city_admin?)
  end

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
