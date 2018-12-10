class StateAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user)
    can :create, State if user.admin?
    can :read, State if user.admin? || support_user?(user)
  end
end
