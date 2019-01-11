# frozen_string_literal: true

class UserAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user)
    can :update_user_system, User if user.admin?
    can :update_user_system, User.where(role: :company_user) if user.company_admin?
    can :update_user_role, User if user.admin?
  end
end
