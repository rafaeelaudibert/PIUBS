# frozen_string_literal: true

class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :filter_role
  before_action :set_category, only: %i[show edit update destroy]
  include ApplicationHelper

  # GET /categories
  # GET /categories.json
  def index
    (@filterrific = initialize_filterrific(
      Category,
      params[:filterrific],
      select_options: { # em breve
      },
      persistence_id: false
    )) || return
    @categories = @filterrific.find.order('id').page(params[:page])
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to @category, notice: 'Category was successfully created.'
    else
      render :new
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    Category.find(params[:id]).destroy
    redirect_to categories_url, notice: 'Category was successfully destroyed.'
  end

  # GET /categories/all
  def all
    respond_to do |format|
      format.js { render json: Category.all.order('id ASC') }
    end
  end

  # GET /categories/category_select/:source
  def category_select
    @source = params[:source]
    render 'category_select', layout: nil
  end

  private

  # Never trust parameters from internet, only allow the white list through.
  def category_params
    parent_id = params[:category][:parent_id]
    params[:category][:parent_depth] = 1 + Category.find(parent_id).parent_depth if parent_id != ''
    params.require(:category).permit(:name, :parent_id,
                                     :parent_depth, :severity, :source)
  end

  def filter_role
    redirect_to denied_path unless admin?
  end
end
