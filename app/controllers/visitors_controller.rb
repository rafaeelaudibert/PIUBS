class VisitorsController < ApplicationController
  include ApplicationHelper

  def index
    if current_user.try(:call_center_user?)
      @calls = Call.where(support_user: [current_user.id, nil]).order(created_at: :desc).paginate(page: params[:page], per_page: 25)
    elsif current_user.try(:call_center_admin?)
      children = [nil]
      User.where(invited_by_id: current_user.id).each do |user|
        children << user.id
      end
      @calls = Call.where(support_user: children).order(created_at: :desc).paginate(page: params[:page], per_page: 25)
    elsif current_user.try(:admin?)
      @calls = Call.order(created_at: :desc).paginate(page: params[:page], per_page: 25)
    elsif current_user.try(:company_admin?)
      @calls = Call.where(sei: current_user.sei).order(created_at: :desc).paginate(page: params[:page], per_page: 25)
    elsif current_user.try(:company_user?)
      @calls = Call.where(user_id: current_user.id).order(created_at: :desc).paginate(page: params[:page], per_page: 25)
    else
      @calls = []
    end
  end
end
