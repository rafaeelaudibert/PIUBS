# frozen_string_literal: true

##
# This is the Ability class for the Unity model
#
# It is responsible for handling the permissions of the
# different User instance <tt>roles</tt> for any Unity
#
# In this case, they are, as follow:
# * User instances with role <tt>admin</tt> can make every
#   request to a Unity
# * User instances with a <tt>support-like</tt> role can
#   <tt>read</tt> every Unity (<tt>index</tt> and <tt>show</tt>)
class UnityAbility
  include CanCan::Ability
  include ApplicationHelper

  # Initialization telling which User instance can do what, following the rules
  # defined above
  def initialize(user)
    can %i[create destroy show], Unity if user.admin?
    can :read, Unity if user.admin? || support_user?(user)
  end
end
