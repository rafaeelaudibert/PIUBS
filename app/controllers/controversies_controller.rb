# frozen_string_literal: true

class ControversiesController < ApplicationController
  before_action :set_controversy, only: %i[show edit update destroy]

  # GET /controversies
  # GET /controversies.json
  def index
    @controversies = Controversy.all
  end

  # GET /controversies/1
  # GET /controversies/1.json
  def show
    @reply = Reply.new
  end

  # GET /controversies/new
  def new
    @controversy = Controversy.new
  end

  # GET /controversies/1/edit
  def edit; end

  # POST /controversies
  # POST /controversies.json
  def create
    controversy_parameters = controversy_params

    files = retrieve_files controversy_parameters
    @controversy = create_controversy controversy_parameters

    if @controversy.save
      create_file_links @controversy, files
      ControversyMailer.notify(@controversy.protocol, current_user.id).deliver_later
      redirect_to @controversy, notice: 'Controvérsia criada com sucesso.'
    else
      render :new
    end
  end

  # PATCH/PUT /controversies/1
  # PATCH/PUT /controversies/1.json
  def update
    respond_to do |format|
      if @controversy.update(controversy_params)
        format.html { redirect_to @controversy, notice: 'Controvérsia atualizada com sucesso' }
        format.json { render :show, status: :ok, location: @controversy }
      else
        format.html { render :edit }
        format.json { render json: @controversy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /controversies/1
  # DELETE /controversies/1.json
  def destroy
    @controversy.destroy
    respond_to do |format|
      format.html { redirect_to controversies_url, notice: 'Controvérsia apagada com sucesso' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_controversy
    @controversy = Controversy.find(params[:id])
  end

  def retrieve_files(parameters)
    parameters.delete(:files).split(',') if parameters[:files]
  end

  def create_controversy(parameters)
    controversy = Controversy.new(parameters)
    controversy.protocol = Time.now.strftime('%Y%m%d%H%M%S%L').to_i
    controversy.contract_id = 1
    controversy.city_id ||= current_user.city_id
    controversy.cnes ||= current_user.cnes
    controversy.open!
    controversy.complexity = 1
    controversy.creator = map_role_to_creator
    controversy[map_role_to_creator + '_user_id'] = current_user.id
    controversy
  end

  def map_role_to_creator
    {
      company_user: 'company',
      company_admin: 'company',
      ubs_admin: 'unity',
      ubs_user: 'unity',
      call_center_admin: 'support',
      call_center_user: 'support',
      city_admin: 'city'
    }[current_user.role.to_sym]
  end

  def create_file_links(controversy, files)
    files.each do |file_uuid|
      @link = AttachmentLink.new(attachment_id: file_uuid, controversy_id: controversy.protocol,
                                 source: 'controversy')
      unless @link.save
        raise 'Não consegui criar o link entre arquivo e a Controvérsia.'\
              ' Por favor tente mais tarde'
      end
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def controversy_params
    params.require(:controversy).permit(:title, :description, :protocol, :closed_at, :sei,
                                        :contract_id, :city_id, :cnes, :company_user_id,
                                        :unity_user_id, :creator, :category, :complexity,
                                        :support_1_id, :support_2_id, :files)
  end
end
