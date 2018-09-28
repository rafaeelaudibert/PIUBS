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
    view_flow.set :layout, capture { yield }
    render "layouts/#{parent_layout}", params: params
  end

  # User helper
  def is_admin?
    current_user.try(:admin?)
  end

  def is_ubs_user?
    current_user.try(:ubs_admin?) || current_user.try(:ubs_user?)
  end

  def is_company_user?
    current_user.try(:company_user?) || current_user.try(:company_admin?)
  end

  def is_support_user?
    current_user.try(:call_center_user?) || current_user.try(:call_center_admin?)
  end

  def is_city_user?
    current_user.try(:city_admin?) || current_user.try(:city_user?)
  end

  def is_company_user # TODO: DEPRECATE IN FAVOR OF IS_COMPANY_USER?
    current_user.try(:company_user?) || current_user.try(:company_admin?)
  end

  def is_support_user # TODO: DEPRECATE IN FAVOR OF IS_SUPPORT_USER?
    current_user.try(:call_center_user?) || current_user.try(:call_center_admin?)
  end
end
