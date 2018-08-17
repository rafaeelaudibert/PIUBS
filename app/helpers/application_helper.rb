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

  def is_company_user
     current_user.try(:company_user?) or current_user.try(:company_admin?)
  end

  def is_support_user
    current_user.try(:call_center_user?) or current_user.try(:call_center_admin?)
  end
end
