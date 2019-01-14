# frozen_string_literal: true

class UnitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_unity, only: %i[show destroy]
  include ApplicationHelper
  load_and_authorize_resource

  # GET /unities
  def index
    (@filterrific = initialize_filterrific(Unity, params[:filterrific],
      select_options: options_for_filterrific,
      persistence_id: false)) || return
    @unities = filterrific_query
  end

  # GET /unities/1
  def show
    @contract = City.find(@unity.city_id).contract
  end

  # GET /unities/new
  def new
    @unity = Unity.new
    @city = City.find(params[:city]) if params[:city]
  end

  # POST /unities
  def create
    @unity = Unity.new(unity_params)
    if @unity.save
      redirect_to new_user_invitation_path(city_id: @unity.city_id,
                                           unity_id: @unity.id,
                                           role: 'ubs_admin'),
                  notice: 'Unity successfully created. Please add its responsible'
    else
      render :new
    end
  end

  # DELETE /unities/1
  # DELETE /unities/1.json
  def destroy
    @unity.destroy
    redirect_to unities_url, notice: 'Unity was successfully destroyed.'
  end

  # GET /cities/:cnes/users
  def users
    respond_to do |format|
      format.js { render json: User.where(cnes: params[:cnes]).order('id ASC') }
    end
  end

  private

  ####
  # :section: Filterrific methods
  # Method related to the Filterrific Gem
  ##

  # Filterrific method
  #
  # Configures the basic options for the
  # <tt>Filterrific</tt> queries
  def options_for_filterrific
    {
      with_state: State.all.map {|s| [s.name, s.id] },
      with_city: [],
    }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_unity
    @unity = Unity.find(params[:cnes])
  end

  # Never trust parameters from internet, only allow the white list through.
  def unity_params
    params.require(:unity).permit(:cnes, :name, :city_id)
  end

  def current_ability
    @current_ability ||= UnityAbility.new(current_user)
  end
end
