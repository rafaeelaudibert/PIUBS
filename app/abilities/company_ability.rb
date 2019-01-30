# frozen_string_literal: true

##
# This is the Ability class for the Company model
#
# It is responsible for handling the permissions of the
# different User instance <tt>roles</tt> for any Company
#
# In this case, they are, as follow:
# * User instances which belong to the related Company instance can
#   <tt>make_api_calls</tt> and acess the Company <tt>show</tt> page
# * User instances which belong to a Company instance, CANNOT access
#   the <tt>index</tt> page
# * User instances with role <tt>admin</tt> can make any possible
#   request to a Company
# * User instances with a <tt>support-like</tt> role can <tt>make_api_calls</tt>
#   and access the <tt>show</tt> page of any Company instance
class CompanyAbility
  include CanCan::Ability
  include ApplicationHelper

  # Initialization telling which User instance can do what, following the rules
  # defined above
  def initialize(user)
    check_company_user_permissions

    can %i[create destroy index], Company if user.admin?
    can %i[make_api_calls show], Company if user.admin? || support_user?(user)
  end

  def check_company_user_permission
    can %i[make_api_calls show], user.company if company_user?(user)
    cannot :index, Company if company_user?(user)
  end
end
