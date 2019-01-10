# frozen_string_literal: true

##
# This is the Ability class for the Feedback model
#
# It is responsible for handling the permissions of the
# different User instance <tt>roles</tt> for any Feedback
#
# In this case, they are, as follow:
# * User instances with role <tt>admin</tt> can <tt>read</tt> and <tt>create</tt>
#   Feedback instances, as well as access their <tt>index</tt> page
# * User instances with a <tt>support-like</tt> role can <tt>create</tt> and
#   access <tt>index</tt> view for any Feedback
class FeedbackAbility
  include CanCan::Ability
  include ApplicationHelper

  # "Fake" Initialization just checking the User instance passed as a parameter
  # has acess to the system Solucao de Controversias
  def initialize(user)
    initializer(user) if user.both? || user.controversies?
  end

  private

  # Initialization telling which User instance can do what, following the rules
  # defined above
  def initializer(user)
    can %i[create index], Feedback if support_user?(user) || user.admin?

    can :read, Feedback if user.admin?
  end
end
