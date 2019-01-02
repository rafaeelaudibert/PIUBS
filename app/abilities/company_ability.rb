# frozen_string_literal: true

class CompanyAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user)
    can %i[make_api_calls show], Company.where(sei: user.sei) if company_user?(user)
    cannot :index, Company if company_user?(user)

    can %i[create destroy index], Company if user.admin?
    can %i[make_api_calls show], Company if user.admin? || support_user?(user)
  end
end

# def filter_role
#   action = params[:action]
#   if %w[index new create destroy].include? action
#     redirect_to denied_path unless admin?
#   elsif %w[states users cities unities].include? action
#     redirect_to denied_path unless can_see_company_api?
#   elsif action == 'show'
#     redirect_if_cant_show
#   end
# end
#
# def redirect_if_cant_show
#   redirect_to denied_path unless sei_company_admin_or_admin?
# end
#
# def can_see_company_api?
#   admin? || support_user? || params[:id].to_i == current_user.sei
# end
#
# def sei_company_admin_or_admin?
#   (current_user.company_admin? && @company.sei == current_user.sei) || admin?
# end
