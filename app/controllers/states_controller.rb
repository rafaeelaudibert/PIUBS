# frozen_string_literal: true

class StatesController < ApplicationController
  before_action :authenticate_user!
  include ApplicationHelper
  load_and_authorize_resource

  # GET /states
  # GET /states.json
  def index
    (@filterrific = initialize_filterrific(
      State,
      params[:filterrific],
      select_options: { # em breve
      },
      persistence_id: false
    )) || return
    @states = @filterrific.find.order(:name).page(params[:page])
  end

  # GET /states/1
  # GET /states/1.json
  def show
    @state = State.find(params[:id])
    @cities = @state.cities.paginate(page: params[:page], per_page: 25)
  end

  # GET /states/new
  def new
    @state = State.new
  end

  # POST /states
  def create
    @state = State.new(state_params)

    if @state.save
      redirect_to @state, notice: 'Estado criado com sucesso.'
    else
      render :new
    end
  end

  private

  # Never trust parameters from the internet, only allow the white list through.
  def state_params
    params.require(:state).permit(:name)
  end

  def current_ability
    @current_ability ||= StateAbility.new(current_user)
  end
end
