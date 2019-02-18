# frozen_string_literal: true

##
# This is the Ability class for the City model
#
# It is responsible for handling the permissions of the
# different User instance <tt>roles</tt> for any City
#
# In this case, they are, as follow:
# * User instances with role <tt>admin</tt> can <tt>create, read</tt>
#   and <tt>make_api_calls</tt> to any City
# * User instances with <tt>support-like</tt> roles can <tt>read</tt>
#   and <tt>make_api_calls</tt> to any City
class CityAbility
  include CanCan::Ability
  include ApplicationHelper

  # Initialization telling which User instance can do what, following the rules
  # defined above
  def initialize(user)
    can :create, City if user.admin?
    can %i[read make_api_calls], City if user.admin? || support_user?(user)
  end
end
