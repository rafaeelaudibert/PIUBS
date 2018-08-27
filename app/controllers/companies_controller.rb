class CompaniesController < ApplicationController
  # before_action :admin_only
  before_action :set_company, only: %i[show edit update destroy]

  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.paginate(page: params[:page], per_page: 25)
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @contracts = Contract.where('sei = ?', @company.sei)
    @contracts = @contracts.paginate(page: params[:page], per_page: 25)
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit; end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      begin
        if @company.save
          format.html { redirect_to new_user_invitation_path(sei: @company.sei), notice: 'Company was successfully created. Please add its admin' }
          format.json { render :show, status: :created, location: @company }
        else
          handleError format, :new, ''
        end
      rescue StandardError
        handleError format, :new, 'This sei already exists in the database.'
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      begin
        if @company.update(company_params)
          format.html { redirect_to @company, notice: 'Company was successfully updated.' }
          format.json { render :show, status: :ok, location: @company }
        else
          handleError format, :edit, ''
        end
      rescue StandardError
        handleError format, :edit, 'This SEI already exists in the database'
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:sei])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def company_params
    params.require(:company).permit(:sei)
  end

  # Handle repeated values errors
  def handleError(format, method, message)
    @company.errors.add(:sei, :blank, message: message) unless message == ''
    format.html { render method }
    format.json { render json: @company.errors, status: :unprocessable_entity }
  end

  def admin_only
    unless current_user.try(:admin?)
      redirect_to not_found_path, alert: 'Access denied.'
    end
  end
end
