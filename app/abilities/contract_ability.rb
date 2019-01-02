# frozen_string_literal: true

class ContractAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user)
    can :download, Contract.where(sei: user.sei) if company_user?(user)

    can %i[index new destroy download], Contract if user.admin?
  end
end
