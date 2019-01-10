# frozen_string_literal: true

##
# This is the Ability class for the Contract model
#
# It is responsible for handling the permissions of the
# different User instance <tt>roles</tt> for any Contract
#
# In this case, they are, as follow:
# * User instances with role <tt>admin</tt> can access the <tt>index</tt>,
#   <tt>new, destroy</tt> and <tt>download</tt> views for any Contract
# * User instances with a <tt>company-like</tt> role can <tt>download</tt> a
#   Contract if he belongs to his related Company
class ContractAbility
  include CanCan::Ability
  include ApplicationHelper

  # Initialization telling which User instance can do what, following the rules
  # defined above
  def initialize(user)
    can %i[index new destroy download], Contract if user.admin?

    can :download, Contract.from_company(user.sei) if company_user?(user)
  end
end
