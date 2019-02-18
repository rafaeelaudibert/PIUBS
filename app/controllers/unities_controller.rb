# frozen_string_literal: true

##
# This is the controller for the Unity model
#
# It is responsible for handling the views for any Unity
class UnitiesController < ApplicationController
  include ApplicationHelper

  # Hooks Configuration
  before_action :authenticate_user!
  before_action :set_unity, only: %i[show destroy]

  # CanCanCan Configuration
  load_and_authorize_resource

  ####
  # :section: View methods
  # Method related to generating views
  ##

  # Configures the <tt>index</tt> page for the Unity model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/unities</tt>
  # [GET] <tt>/unities.json</tt>
  def index
    (@filterrific = initialize_filterrific(
      Unity,
      params[:filterrific],
      select_options: options_for_filterrific,
      persistence_id: false
    )) || return
    @unities = filterrific_query
  end

  # Configures the <tt>show</tt> page for the Unity model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/unities/:id</tt>
  # [GET] <tt>/unities/:id.json</tt>
  def show
    @contract = @unity.city.contract
  end

  # Configures the <tt>new</tt> page for the Unity model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/unities/new</tt>
  def new
    @unity = Unity.new
    @city = City.find(params[:city]) if params[:city]
  end

  # Configures the <tt>POST</tt> request to create a new Unity
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/unities</tt>
  def create
    @unity = Unity.new(unity_params)
    if @unity.save
      redirect_to new_user_invitation_path(city_id: @unity.city_id,
                                           unity_id: @unity.id,
                                           role: 'ubs_admin'),
                  notice: 'UBS criada com sucesso! Por favor, adicione o seu responsável.'
    else
      render :new
    end
  end

  # Configures the <tt>DELETE</tt> request to delete a Unity
  #
  # <b>ROUTES</b>
  #
  # [DELETE] <tt>/unities/:id</tt>
  def destroy
    @unity.destroy
    redirect_to unities_url, notice: 'UBS apagada com sucesso.'
  end

  # Configures the <tt>users</tt> request for the Unity model
  # It returns all User instances which are children of the
  # queried Unity
  #
  # <b>OBS.:</b> This view only exist in a JSON format
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/unities/:id/users.json</tt>
  def users
    @users = User.from_ubs params[:cnes]
  end

  private

  ####
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file
  ##

  # Configures the Unity instance when called by
  # the <tt>:before_action</tt> hook
  def set_unity
    @unity = Unity.find(params[:cnes])
  end

  # :section: Filterrific methods
  # Method related to the Filterrific Gem
  ##

  # Filterrific method
  #
  # Configures the basic options for the
  # <tt>Filterrific</tt> queries
  def options_for_filterrific
    {
      with_state: State.all.map { |s| [s.name, s.id] },
      with_city: []
    }
  end

  ####
  # :section: Custom private methods
  ##

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def unity_params
    params.require(:unity).permit(:cnes, :name, :city_id)
  end

  ####
  # :section: CanCanCan methods
  # Methods which are related to the CanCanCan gem
  ##

  # CanCanCan Method
  #
  # Default CanCanCan Method, declaring the UnityAbility
  def current_ability
    @current_ability ||= UnityAbility.new(current_user)
  end
end
