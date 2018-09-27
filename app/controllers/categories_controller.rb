class CategoriesController < ApplicationController
  before_action :set_category, only: %i[show edit update destroy]
  before_action :filter_role
  include ApplicationHelper

  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.paginate(page: params[:page], per_page: 25)
  end

  # GET /categories/1
  # GET /categories/1.json
  def show; end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit; end

  # POST /categories
  # POST /categories.json
  def create
    puts category_params
    @category = Category.new(category_params)
    if @category.save
      redirect_to @category, notice: 'Category was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    if @category.update(category_params)
      redirect_to @category, notice: 'Category was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    redirect_to categories_url, notice: 'Category was successfully destroyed.'
  end

  # GET /categories/all
  def all
    respond_to do |format|
      format.js { render json: Category.all.order('id ASC') }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = Category.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def category_params
    puts params
    parent_id = params[:category][:parent_id]
    puts parent_id
    params[:category][:parent_depth] = 1 + Category.find(parent_id).parent_depth if parent_id
    params.require(:category).permit(:name, :parent_id, :parent_depth)
  end

  def filter_role
    redirect_to denied_path unless is_admin?
  end
end
