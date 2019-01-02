# frozen_string_literal: true

class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contract, only: %i[destroy download]
  include ApplicationHelper

  load_and_authorize_resource
  skip_authorize_resource only: :download

  # GET /contracts
  def index
    (@filterrific = initialize_filterrific(Contract,
                                           params[:filterrific],
                                           select_options: {}, # em breve
                                           persistence_id: false)) || return
    @contracts = @filterrific.find.order(:sei).page(params[:page])
  end

  # GET /contracts/new
  def new
    @contract = Contract.new
    @city = City.find(params[:city]) if params[:city]
    @company = Company.find(params[:company]) if params[:company]
  end

  # POST /contracts
  def create
    @contract = Contract.new(contract_params)
    if one_city? # If there already is a city with this ID in the database
      @contract.errors.add(:city_id, :blank, message: 'Essa cidade já possui um contrato')
      render :new
    elsif !check_pdf
      @contract.errors.add(:filename, :blank,
                           message: 'Você precisa inserir um contrato em formato PDF')
      render :new
    elsif @contract.save
      redirect_to @contract, notice: 'Contrato criado com sucesso.'
    else
      render :new
    end
  end

  # DELETE /contracts/1
  def destroy
    @contract.destroy
    redirect_to contracts_url, notice: 'Contrato apagado com sucesso.'
  end

  # GET /contract/:id/download
  def download
    authorize! :download, @contract
    if @contract.content_type.split('/')[1].to_s == 'pdf'
      send_data(@contract.file_contents, type: @contract.content_type, filename: @contract.filename)
    end
  rescue StandardError
    redirect_to not_found_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_contract
    @contract = Contract.find(params[:id])
  end

  # Never trust parameters from internet, only allow the white list through.
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
  def one_city?
    ans = Contract.where(city_id: params.require(:contract).require(:city_id)).first
    !ans.nil? # Returns true if there already is a city with this
  end

  # Checks if the file is a PDF
  def check_pdf
    file = params.require(:contract).require(:file)
    return file.content_type.split('/')[1].to_s == 'pdf' if file

    false
  end

  def current_ability
    @current_ability ||= ContractAbility.new(current_user)
  end
end
