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
  def admin?
    current_user.try(:admin?)
  end

  def admin_like?
    current_user.try(:admin?) || current_user.try(:ubs_admin?) ||
    current_user.try(:company_admin?) || current_user.try(:call_center_admin?) ||
    current_user.try(:city_admin?)
  end

  def ubs_user?
    current_user.try(:ubs_admin?) || current_user.try(:ubs_user?)
  end

  def company_user?
    current_user.try(:company_user?) || current_user.try(:company_admin?)
  end

  def support_user?
    current_user.try(:call_center_user?) || current_user.try(:call_center_admin?)
  end

  def city_user?
    current_user.try(:city_admin?)
  end

  def faq_inserter?
    current_user.try(:faq_inserter?)
  end
end
