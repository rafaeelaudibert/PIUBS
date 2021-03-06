# frozen_string_literal: true

##
# This is the controller for the Category model
#
# It is responsible for handling the views for any Category
class CategoriesController < ApplicationController
  include ApplicationHelper

  # Hooks Configuration
  before_action :authenticate_user!

  # CanCanCan Configuration
  load_and_authorize_resource

  ####
  # :section: View methods
  # Method related to generating views
  ##

  # Configures the <tt>index</tt> page for the Category model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/categories</tt>
  # [GET] <tt>/categories.json</tt>
  def index
    (@filterrific = initialize_filterrific(
      Category,
      params[:filterrific],
      persistence_id: false
    )) || return
    @categories = filterrific_query
  end

  # Configures the <tt>new</tt> page for the Category model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/categories/new</tt>
  def new
    @category = Category.new
  end

  # Configures the <tt>POST</tt> request to create a
  # new Category
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/categories</tt>
  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to @category, notice: 'Categoria criada com sucesso.'
    else
      render :new
    end
  end

  # Configures the <tt>DELETE</tt> request to delete
  # a Category
  #
  # <b>ROUTES</b>
  #
  # [DELETE] <tt>/categories/:id</tt>
  def destroy
    @category = Category.find(params[:id])
    if @category.answers.empty?
      @category.destroy
      redirect_to categories_url, notice: 'Categoria apagada com sucesso'
    else
      redirect_back fallback_location: categories_path,
                    alert: 'Não podemos apagar essa categoria, pois ela possui Respostas Finais'
    end
  end

  # Configures the layout to create a
  # <tt>HTML select tag</tt> with all the categories
  # from a given source (system)
  #
  # [GET] <tt>/categories/category_select/:source</tt>
  def category_select
    @source = params[:source]
    render 'category_select', layout: nil
  end

  private

  ####
  # :section: Custom private methods
  ##

  # Makes the famous "Never trust parameters from internet, only allow the white list through.".
  def category_params
    parent_id = params[:category][:parent_id]
    params[:category][:parent_depth] = 1 + Category.find(parent_id).parent_depth if parent_id != ''
    params.require(:category).permit(:name, :parent_id,
                                     :parent_depth, :severity, :source)
  end

  ####
  # :section: CanCanCan methods
  # Methods which are related to the CanCanCan gem
  ##

  # CanCanCan Method
  #
  # Default CanCanCan Method, declaring the CategoryAbility
  def current_ability
    @current_ability ||= CategoryAbility.new(current_user)
  end
end
