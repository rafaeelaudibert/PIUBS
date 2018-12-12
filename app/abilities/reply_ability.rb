# frozen_string_literal: true

class ReplyAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user)
    can :create, Reply # Everybody can create replies
    can :read, Reply if user.admin?
    can :verify_attachments, Reply if user.admin? || support_user?(user)
  end
end
