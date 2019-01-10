# frozen_string_literal: true

##
# This is the Ability class for the Controversy model
#
# It is responsible for handling the permissions of the
# different User instance <tt>roles</tt> for any Controversy
#
# In this case, they are, as follow:
# * <b>Everybody</b> EXCEPT User instances with role <tt>faq_inserter</tt> can
#   access <tt>index</tt> and <tt>create</tt> a new Controversy
# * User instances can <tt>show</tt> a Controversy if he is in his "assigned"
#   role in the Controversy, i.e.: a User instance with a <tt>city_user</tt> role
#   needs to be in the <tt>city_user_id</tt> field of the Controversy to access it
# * User instances with an <tt>admin</tt> role can execute any request to the
#   Controversy, EXCEPT <tt>link</tt> related requests
# * User instances with a <tt>support-like</tt> role can execute <tt>link</tt> and
#   <tt>alter_user</tt> (if this User instance is on the <tt>support_1_user_id</tt>
#   field of the Controversy) requests as well as access the <tt>show</tt> page
#   for any Controversy
class ControversyAbility
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
    can %i[index create], Controversy unless user.faq_inserter?

    admin_abilities user
    support_abilities user
    manage_show_abilities user
  end

  # Called by #initialize, this manages the permission for User instances
  # with the <tt>admin</tt> role
  def admin_abilities(user)
    can :manage, Controversy if user.admin?
    can :alter_user, Controversy if user.admin?
  end

  # Called by #initialize, this manages the permission for User instances
  # with a <tt>support_like</tt> role
  def support_abilities(user)
    can :link, Controversy if support_like?(user)
    can :alter_user, Controversy.for_support_user(user.id) if support_user?(user)
    can :show, Controversy if support_user?(user)
  end

  # Called by #initialize, this manages the permission for the <tt>show</tt> view
  def manage_show_abilities(user)
    can :show, Controversy.for_company(user.sei) if user.company_admin?
    can :show, Controversy.for_company_user(user.id)
    can :show, Controversy.for_city_user(user.id)
    can :show, Controversy.for_unity_user(user.id)
  end
end
