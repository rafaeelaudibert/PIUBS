class ContractsController < ApplicationController
  before_action :set_contract, only: %i[show edit update destroy download]

  # GET /contracts
  # GET /contracts.json
  def index
    @contracts = Contract.paginate(page: params[:page], per_page: 25)
  end

  # GET /contracts/1
  # GET /contracts/1.json
  def show; end

  # GET /contracts/new
  def new
    @contract = Contract.new
    @city = City.find(params[:city]) if params[:city]
    @company = Company.find(params[:company]) if params[:company]
  end

  # GET /contracts/1/edit
  def edit
    @city = City.find(@contract.city_id)
    @company = Company.find(@contract.sei)
  end

  # POST /contracts
  # POST /contracts.json
  def create
    @contract = Contract.new(contract_params)

    respond_to do |format|
      if hasOneCity # If there already is a city with this ID in the database
        @contract.errors.add(:city_id, :blank, message: 'This city already have a contract linked to it')
        format.html { render :new }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      elsif !checkPDF
        @contract.errors.add(:filename, :blank, message: 'You must insert a file and it MUST be in the PDF format')
        format.html { render :edit }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      elsif @contract.save
        format.html { redirect_to @contract, notice: 'Contract was successfully created.' }
        format.json { render :show, status: :created, location: @contract }
      else
        format.html { render :new }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contracts/1
  # PATCH/PUT /contracts/1.json
  def update
    respond_to do |format|
      if hasOneCityEdit(@contract.city_id) # If there already is a city with this ID in the database
        @contract.errors.add(:city_id, :blank, message: 'This city already have a contract linked to it')
        format.html { render :edit }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      elsif !checkPDF
        @contract.errors.add(:filename, :blank, message: 'You must insert a file and it MUST be in the PDF format')
        format.html { render :edit }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      elsif @contract.update(contract_params)
        format.html { redirect_to @contract, notice: 'Contract was successfully updated.' }
        format.json { render :show, status: :ok, location: @contract }
      else
        format.html { render :edit }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contracts/1
  # DELETE /contracts/1.json
  def destroy
    @contract.destroy
    respond_to do |format|
      format.html { redirect_to contracts_url, notice: 'Contract was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /contract/:id/download
  def download
    send_data(@contract.file_contents, type: @contract.content_type, filename: @contract.filename) if @contract.content_type.split('/')[1].to_s == 'pdf'
  rescue StandardError
    redirect_to not_found_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_contract
    @contract = Contract.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  # Also optimize the file data, separating it in filename, content_type & file_contents
  def contract_params
    parameters = params.require(:contract).permit(:file, :contract_number, :city_id, :sei)
    file = parameters.delete(:file) if parameters
    if file
      parameters[:filename] = File.basename(file.original_filename)
      parameters[:content_type] = file.content_type
      parameters[:file_contents] = file.read
    end
    parameters
  end

  # Try to see if the city already have a contract
  def hasOneCity
    ans = Contract.where('city_id = ?', params.require(:contract).require(:city_id)).first
    !ans.nil? # Returns true if there already is a city with this
  end

  # Try to see if the city already have a contract during the edit
  def hasOneCityEdit(_id)
    city_id = params.require(:contract).require(:city_id)
    ans = Contract.where('city_id = ?', city_id).first
    !(ans.nil? || city_id == _id.to_s) # If this city doesn't have a contract or is the same city that we have in the contract now
  end

  # Checks if the file is a PDF
  def checkPDF
    file = params.require(:contract).require(:file)
    return file.content_type.split('/')[1].to_s == 'pdf' if file
    false
  end
end
