# frozen_string_literal: true

class AnswerAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user)
    can :read, Answer.where(faq: true) # Everybody can read the FAQs and query it
    can :query_faq, Answer

    can :manage, Answer if user.admin?
    can :create, Answer if faq_creator?(user)
    can %i[read update destroy], Answer.where(user_id: user.id) if faq_creator?(user)
  end

  def faq_creator?(user)
    user.faq_inserter? || support_user?(user)
  end
end
