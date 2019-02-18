# frozen_string_literal: true

##
# This is the Ability class for the User model
#
# It is responsible for handling the permissions of the
# different User instance <tt>roles</tt> for any User
#
# In this case, they are, as follow:
# * User instances with role <tt>admin</tt> can update any other User
#   instance <tt>system</tt> and <tt>role</tt>
# * User instances with a <tt>company_admin</tt> role can
#   update the <tt>system</tt> for User instances with role
#   <tt>company_user</tt> which were invited by him
class UserAbility
  include CanCan::Ability
  include ApplicationHelper

  # Initialization telling which User instance can do what, following the rules
  # defined above
  def initialize(user)
    can :update_user_system, User if user.admin?
    can :update_user_system, User.invited_by(user.id) if user.company_admin?
    can :update_user_role, User if user.admin?
  end
end
