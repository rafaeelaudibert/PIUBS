# frozen_string_literal: true

class UnityAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user)
    can %i[create destroy show], Unity if user.admin?
    can :read, Unity if user.admin? || support_user?(user)
  end
end
