# frozen_string_literal: true

##
# This is the controller for the Company model
#
# It is responsible for handling the views for any Company
class ContractsController < ApplicationController
  include ApplicationHelper

  ##########################
  ## Hooks Configuration ###

  before_action :authenticate_user!
  before_action :filter_role
  before_action :set_contract, only: %i[destroy download]

  ##########################
  # :section: View methods
  # Method related to generating views

  # Configures the <tt>index</tt> page for the Contract model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/contracts</tt>
  # [GET] <tt>/contracts.json</tt>
  def index
    (@filterrific = initialize_filterrific(Contract,
                                           params[:filterrific],
                                           persistence_id: false)) || return
    @contracts = @filterrific.find.page(params[:page])
  end

  # Configures the <tt>new</tt> page for the Contract model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/contracts/new</tt>
  def new
    @contract = Contract.new
    @city = City.find(params[:city]) if params[:city]
    @company = Company.find(params[:company]) if params[:company]
  end

  # Configures the <tt>POST</tt> request to create a new Contract
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/contracts</tt>
  def create
    @contract = Contract.new(contract_params)
    @city = @contract.city

    if city_has_contract? # If there already is a city with this ID in the database
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

  # Configures the <tt>DELETE</tt> request to delete a Contract
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/contracts/:id</tt>
  def destroy
    @contract.destroy
    redirect_to contracts_url, notice: 'Contrato apagado com sucesso.'
  end

  # Configures the <tt>download</tt> request for a Contract
  #
  # It prompts the browser to download the file
  # from the system
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/contracts/:id/download</tt>
  def download
    if @contract.content_type.split('/')[1].to_s == 'pdf'
      send_data(@contract.file_contents, type: @contract.content_type, filename: @contract.filename)
    end
  rescue StandardError
    redirect_to not_found_path
  end

  private

  ##########################
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file

  # Configures the Contract instance when called by
  # the <tt>:before_action</tt> hook
  def set_contract
    @contract = Contract.find(params[:id])
  end

  ##########################
  # :section: Custom private method

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  # Also optimizes the file data, separating it in filename, content_type & file_contents
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

  # Called by #create, verifies if the city already
  # has a contract
  def city_has_contract?
    !@city.contract.nil?
  end

  # Called by #create, checks if the file is a PDF
  def check_pdf
    file = params.require(:contract).require(:file)
    return file.content_type.split('/')[1].to_s == 'pdf' if file

    false
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Filters the access to each of the actions of the controller
  def filter_role
    action = params[:action]
    if %w[index new create destroy].include? action
      redirect_to denied_path unless admin?
    elsif action == 'download'
      redirect_to denied_path unless admin? || sei_company_admin?
    end
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Called by #filter_role, verifies if the
  # <tt>current_user</tt> is the <tt>company_admin</tt>
  # of the Company related to the Contract
  def sei_company_admin?
    current_user.try(:company_admin?) && @contract.sei == current_user.sei
  end
end
