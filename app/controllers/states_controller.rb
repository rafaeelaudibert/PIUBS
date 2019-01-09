# frozen_string_literal: true

##
# This is the controller for the State model
#
# It is responsible for handling the views for any State
class StatesController < ApplicationController
  include ApplicationHelper

  ##########################
  ## Hooks Configuration ###

  before_action :authenticate_user!
  before_action :filter_role

  ##########################
  # :section: View methods
  # Method related to generating views

  # Configures the <tt>index</tt> page for the State model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/states</tt>
  # [GET] <tt>/states.json</tt>
  def index
    (@filterrific = initialize_filterrific(
      State,
      params[:filterrific],
      persistence_id: false
    )) || return
    @states = @filterrific.find.page(params[:page])
  end

  # Configures the <tt>show</tt> page for the State model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/states/:id</tt>
  # [GET] <tt>/states/:id.json</tt>
  def show
    @state = State.find(params[:id])
    @cities = @state.cities.paginate(page: params[:page], per_page: 25)
  end

  # Configures the <tt>new</tt> page for the State model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/states/new</tt>
  def new
    @state = State.new
  end

  # Configures the <tt>POST</tt> request to create a new State
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/states</tt>
  def create
    @state = State.new(state_params)
    if @state.save
      redirect_to @state, notice: 'Estado criado com sucesso.'
    else
      render :new
    end
  end

  # Configures the <tt>cities</tt> request for the State model
  # It returns all City instances which are children of the
  # queried State
  #
  # <b>OBS.:</b> This view only exist in a JSON format
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/states/:id/cities.json</tt>
  def cities
    @state = State.find(params[:id])
    @cities = @state.cities
  end

  private

  ##########################
  # :section: Custom private methods

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def state_params
    params.require(:state).permit(:name)
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Filters the access to each of the actions of the controller
  def filter_role
    action = params[:action]
    if %w[new create].include? action
      redirect_to denied_path unless admin?
    elsif %w[index show].include? action
      redirect_to denied_path unless admin? || support_user?
    end
  end
end
