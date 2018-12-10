class CityAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user)
    can :create, City if user.admin?
    can :read, City if user.admin? || support_user?(user)
  end
end
