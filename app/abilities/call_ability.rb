# frozen_string_literal: true

class CallAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user)
    can %i[index create], Call # Every user can acess the index or create a new Call

    # Only the creator can destroy his own call
    can :destroy, Call.where(user_id: user.id) if company_user?(user)

    manage_show_restrictions(user)
    manage_special_actions(user)

    # Total acess to admin
    can :manage, Call if user.admin?
  end

  protected

  def manage_show_restrictions(user)
    can :show, Call if support_user?(user)
    can :show, Call.where(sei: user.sei) if user.company_admin?
    can :show, Call.where(user_id: user.id) if user.company_user?
  end

  def manage_special_actions(user)
    can :link_call, Call if support_user?(user)
    can :reopen_call, Call.where(sei: user.sei) if user.company_admin?
    can :reopen_call, Call.where(user_id: user.id) if user.company_user?
  end
end
