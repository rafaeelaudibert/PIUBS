# frozen_string_literal: true

class CategoryAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user)
    can %i[create read update destroy], Category if user.admin?
  end
end
