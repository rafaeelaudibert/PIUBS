# frozen_string_literal: true

class StatesController < ApplicationController
  before_action :set_state, only: %i[show edit update destroy]
  before_action :filter_role
  include ApplicationHelper

  # GET /states
  # GET /states.json
  def index
    @states = State.paginate(page: params[:page], per_page: 27).order('name ASC')
  end

  # GET /states/1
  # GET /states/1.json
  def show
    @cities = @state.cities.paginate(page: params[:page], per_page: 25)
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
      redirect_to @state, notice: 'Estado criado com sucesso.'
    else
      render :new
    end
  end

  # PATCH/PUT /states/1
  def update
    if @state.update(state_params)
      redirect_to @state, notice: 'Estado atualizado com sucesso.'
    else
      render :edit
    end
  end

  # DELETE /states/1
  def destroy
    @state.destroy
    redirect_to states_url, notice: 'Estado excluído com sucesso.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_state
    @state = State.find(params[:id])
  end

  # Never trust parameters from the internet, only allow the white list through.
  def state_params
    params.require(:state).permit(:name)
  end

  def filter_role
    action = params[:action]
    if %w[new create destroy edit update show].include? action
      redirect_to denied_path unless admin?
    elsif %w[index show].include? action
      redirect_to denied_path unless admin? || support_user?
    end
  end
end
