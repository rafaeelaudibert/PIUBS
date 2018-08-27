class VisitorsController < ApplicationController
  def index
    @calls = Call.paginate(page: params[:page], per_page: 25)
  end
end
