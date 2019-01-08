# frozen_string_literal: true

##
# This is the controller for the City model
#
# It is responsible for handling the views for any City
class CitiesController < ApplicationController
  include ApplicationHelper

  ##########################
  ## Hooks Configuration ###

  before_action :authenticate_user!
  before_action :filter_role

  ##########################
  # :section: View methods
  # Method related to generating views

  # Configures the <tt>index</tt> page for the City model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/cities</tt>
  # [GET] <tt>/cities.json</tt>
  def index
    (@filterrific = initialize_filterrific(
      City,
      params[:filterrific],
      select_options: options_for_filterrific,
      persistence_id: false
    )) || return
    @cities = @filterrific.find.page(params[:page])
  end

  # Configures the <tt>show</tt> page for the City model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/cities/1</tt>
  # [GET] <tt>/cities/1.json</tt>
  def show
    @city = City.find(params[:id])
    @ubs = @city.unity_ids.sort
    @contract = @city.contract
  end

  # Configures the <tt>new</tt> page for the City model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/cities/new</tt>
  def new
    @city = City.new
    @state = State.find(params[:state]) if params[:state]
  end

  # Configures the <tt>POST</tt> request to create a new City
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/cities</tt>
  def create
    @city = City.new(city_params)
    if @city.save
      redirect_to new_user_invitation_path(city_id: @city.id,
                                           role: 'city_admin'),
                  notice: 'Cidade criada com sucesso. Por favor, adicione seu responsável'
    else
      render :new
    end
  end

  # Configures the <tt>unities</tt> request for the City model
  # It returns all Unity instances which are children of the
  # queried City
  #
  # <b>OBS.:</b> This view only exist in a JSON format
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/cities/:id/unities.json</tt>
  def unities
    @city = City.find(params[:id])
    @unities = @city.unities
  end

  # Configures the <tt>users</tt> request for the City model
  # It returns all User instances which are children of the
  # queried City
  #
  # <b>OBS.:</b> This view only exist in a JSON format
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/cities/:id/users.json</tt>
  def users
    @users = User.from_city params[:id]
  end

  private

  ##########################
  # :section: Filterrific methods
  # Method related to the Filterrific Gem

  # Filterrific method
  #
  # Configures the basic options for the
  # <tt>Filterrific</tt> queries
  def options_for_filterrific
    {
      with_state: State.all.map { |s| [s.name, s.id] },
      sorted_by_name: City.options_for_sorted_by_name
    }
  end

  ##########################
  # :section: Custom private methods

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def city_params
    params.require(:city).permit(:name, :state_id)
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
