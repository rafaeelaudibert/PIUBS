# frozen_string_literal: true

class ControversyAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user)
    @user = user
    admin_abilities
    support_abilities

    can %i[index create], Controversy unless user.faq_inserter?
    can :show, Controversy.where(company_user: user)
    can :show, Controversy.where(city_user: user)
    can :show, Controversy.where(unity_user: user)
    can :show, Controversy.where(sei: user.sei)
  end

  protected

  def admin_abilities
    can :manage, Controversy if @user.admin?
    can :alter_user, Controversy if @user.admin?
  end

  def support_abilities
    can :link, Controversy if support_like?(@user)
    can :alter_user, Controversy.where(support_1: @user) if support_user?(@user)
    can :show, Controversy if support_user?(@user)
  end
end
