class VisitorsController < ApplicationController
  def index
    @calls = Call.all
  end
end
