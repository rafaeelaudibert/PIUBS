# frozen_string_literal: true

class CityAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user)
    can :create, City if user.admin?
    can :read, City if user.admin? || support_user?(user)
    can :make_api_calls, City if user.admin? || support_user?(user)
  end
end
