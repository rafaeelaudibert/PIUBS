class VisitorsController < ApplicationController
  def index
    if current_user.try(:call_center_user?) || current_user.try(:call_center_admin?) || current_user.try(:admin?)
      @calls = Call.paginate(page: params[:page], per_page: 25)
    elsif current_user.try(:company_admin?)
      @calls = Call.where('sei = ?', current_user.sei).paginate(page: params[:page], per_page: 25)
    elsif current_user.try(:company_user?)
      @calls = Call.where('user_id = ?', current_user.id).paginate(page: params[:page], per_page: 25)
    else
      @calls = []
    end
  end
end
