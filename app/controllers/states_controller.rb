# frozen_string_literal: true

class StatesController < ApplicationController
  before_action :set_state, only: %i[show edit update destroy]
  before_action :filter_role
  include ApplicationHelper

  # GET /states
  # GET /states.json
  def index
    @states = State.paginate(page: params[:page], per_page: 27)
  end

  # GET /states/1
  # GET /states/1.json
  def show
    @cities = @state.city.order(id: 'ASC').paginate(page: params[:page], per_page: 25)
  end

  # GET /states/new
  def new
    @state = State.new
  end

  # GET /states/1/edit
  def edit; end

  # POST /states
  def create
    @state = State.new(state_params)
    if @state.save
      redirect_to @state, notice: 'State was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /states/1
  def update
    if @state.update(state_params)
      redirect_to @state, notice: 'State was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /states/1
  def destroy
    @state.destroy
    redirect_to states_url, notice: 'State was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_state
    @state = State.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def state_params
    params.require(:state).permit(:name)
  end

  def filter_role
    action = params[:action]
    if %w[new create destroy edit update show].include? action
      redirect_to denied_path unless is_admin?
    elsif %w[index show].include? action
      redirect_to denied_path unless is_admin? || is_support_user
    end
  end
end
