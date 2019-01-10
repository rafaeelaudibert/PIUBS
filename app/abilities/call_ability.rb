# frozen_string_literal: true

##
# This is the Ability class for the Call model
#
# It is responsible for handling the permissions of the
# different User instance <tt>roles</tt> for any Call
#
# In this case, they are, as follow:
# * <b>Everybody</b> (with acess to the Apoio as Empresas system)
#   can access <tt>index</tt> and <tt>create</tt> a Call
# * User with a <tt>company-like</tt> role can <tt>destroy</tt> his own Call
# * User with a <tt>company-like</tt> role can <tt>show</tt> and
#   <tt>reopen</tt> any Call created by it, with the <tt>company_admin</tt>
#   being able to make it so also to any Call created by a <tt>company_user</tt>
#   belonging to the same Company as him
# * User with a <tt>support-like</tt> role can <tt>show</tt> and
#   <tt>link</tt>/<tt>unlink</tt> to any Call
class CallAbility
  include CanCan::Ability
  include ApplicationHelper

  # "Fake" Initialization just checking the User instance passed as a parameter
  # has acess to the system Apoio as Empresas
  def initialize(user)
    initializer(user) if user.both? || user.companies?
  end

  private

  # Initialization telling which User instance can do what, following the rules
  # defined above
  def initializer(user)
    can %i[index create], Call # Every user can acess the index or create a new Call

    # Only the creator can destroy his own call
    can :destroy, Call.from_company_user(user.id) if company_user?(user)

    manage_show_restrictions(user)
    manage_special_actions(user)

    # Total acess to admin
    can :manage, Call if user.admin?
  end

  # Helper to #initializer, managing the restrictions to the <tt>show</tt> action
  def manage_show_restrictions(user)
    can :show, Call if support_user?(user)
    can :show, Call.from_company(user.sei) if user.company_admin?
    can :show, Call.from_company_user(user.id) if user.company_user?
  end

  # Helper to #initializer, managing the restrictions to methods related to
  # <tt>link</tt>/<tt>unlink</tt> <tt>support-like</tt> User instances to a Call
  # and <tt>reopen_call</tt> actions for <tt>company-like</tt> User instances
  def manage_special_actions(user)
    can :link_call, Call if support_user?(user)
    can :reopen_call, Call.from_company(user.sei) if user.company_admin?
    can :reopen_call, Call.from_company_user(user.id) if user.company_user?
  end
end
