# frozen_string_literal: true

##
# This is the Ability class for the Category model
#
# It is responsible for handling the permissions of the
# different User instance <tt>roles</tt> for any Category
#
# In this case, they are, as follow:
# * User instances with role <tt>admin</tt> can <tt>create, read, update</tt> and
# <tt>destroy</tt> any Category instance
class CategoryAbility
  include CanCan::Ability
  include ApplicationHelper

  # Initialization telling which User instance can do what, following the rules
  # defined above
  def initialize(user)
    can %i[create read update destroy], Category if user.admin?
  end
end
