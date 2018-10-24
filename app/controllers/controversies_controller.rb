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
  def show; end

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
    files = controversy_parameters.delete(:files).split(',') if controversy_parameters[:files]

    @controversy = Controversy.new(controversy_parameters)
    @controversy.protocol = Time.now.strftime('%Y%m%d%H%M%S%L').to_i
    @controversy.open!
    @controversy.complexity = 1


    if @controversy.save
      files.each do |file_uuid|
        @link = AttachmentLink.new(attachment_id: file_uuid,
                                   controversy_id: @controversy.protocol,
                                   source: 'controversy')
        unless @link.save
          raise 'Não consegui criar o link entre arquivo e a Controvérsia.'\
                ' Por favor tente mais tarde'
        end
      end

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

  # Never trust parameters from the scary internet, only allow the white list through.
  def controversy_params
    params.require(:controversy).permit(:title, :description, :protocol, :closed_at, :sei,
                                        :contract_id, :city_id, :cnes, :company_user_id,
                                        :unity_user_id, :creator, :category, :complexity,
                                        :support_1_id, :support_2_id, :files)
  end
end
