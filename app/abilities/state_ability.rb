# frozen_string_literal: true

##
# This is the Ability class for the State model
#
# It is responsible for handling the permissions of the
# different User instance <tt>roles</tt> for any State
#
# In this case, they are, as follow:
# * User instances with role <tt>admin</tt> can make every
#   request to a State, even <tt>create</tt> a new one
# * User instances with a <tt>support-like</tt> role can
#   <tt>read</tt> every State (<tt>index</tt> and <tt>show</tt>)
#   and <tt>make_api_calls</tt>
class StateAbility
  include CanCan::Ability
  include ApplicationHelper

  # Initialization telling which User instance can do what, following the rules
  # defined above
  def initialize(user)
    can :create, State if user.admin?
    can %i[read make_api_calls], State if user.admin? || support_user?(user)
  end
end
