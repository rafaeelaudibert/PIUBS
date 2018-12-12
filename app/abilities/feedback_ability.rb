# frozen_string_literal: true

class FeedbackAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user)
    can %i[create index], Feedback if support_user?(user) || user.admin?

    can :read, Feedback if user.admin?
  end
end
