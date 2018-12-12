# frozen_string_literal: true

class ControversyAbility
  include CanCan::Ability
  include ApplicationHelper

  def initialize(user)
    @user = user
    admin_abilities
    support_abilities

    can %i[index create], Controversy unless user.faq_inserter?
    can :show, Controversy.where(company_user: user).or(Controversy.where(city_user: user))
      .or(Controversy.where(unity_user: user))
                          .or(Controversy.where(sei: user.sei))
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

# def filter_role
#   redirect_if_not_in_call if params[:action] == 'show'
# end

# def redirect_if_not_in_call
#   redirect_to denied_path unless in_controversy? || support_like?
# end

# def in_controversy?
#   # User in the controversy or admin of the company involved in the controversy
#   @controversy.all_users.include?(current_user) ||
#     @controversy.sei == current_user.sei
# end
