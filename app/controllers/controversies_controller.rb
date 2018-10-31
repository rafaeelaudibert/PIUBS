# frozen_string_literal: true

class ControversiesController < ApplicationController
  before_action :set_controversy, only: %i[show edit update destroy]
  before_action :filter_role

  # GET /controversies
  # GET /controversies.json
  def index
    @controversies = Controversy.all
  end

  # GET /controversies/1
  # GET /controversies/1.json
  def show
    @reply = Reply.new
    @user_creator = begin
                      User.find(@controversy[@controversy.creator + '_user_id']).name
                    rescue
                      'Sem usuário criador (Relate ao suporte)'
                    end
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
    user_creator = retrieve_user_creator controversy_parameters
    @controversy = create_controversy controversy_parameters, user_creator

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

  # POST /:id/company_user/:user_id
  def company_user
    @controversy = Controversy.find(params[:id])
    @user = User.find(params[:user_id])

    if !@controversy.company_user.nil?
      @controversy.company_user_id = nil
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário removido' : 'Erro na remoção de usuário')
    elsif @user.company_id == @controversy.company_id
      @controversy.company_user = @user
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário adicionado' : 'Erro na adição de usuário')
    else
      redirect_to @controversy, alert: 'Usuário sem permissão para ser adicionado'
    end
  end

  # POST /:id/city_user/:user_id
  def city_user
    @controversy = Controversy.find(params[:id])
    @user = User.find(params[:user_id])

    if !@controversy.city_user.nil?
      @controversy.city_user_id = nil
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário removido' : 'Erro na remoção de usuário')
    elsif @user.city_id == @controversy.city_id && @user.cnes.nil?
      @controversy.city_user = @user
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário adicionado' : 'Erro na adição de usuário')
    else
      redirect_to @controversy, alert: 'Usuário sem permissão para ser adicionado'
    end
  end

  # POST /:id/unity_user/:user_id
  def unity_user
    @controversy = Controversy.find(params[:id])
    @user = User.find(params[:user_id])

    if !@controversy.unity_user.nil?
      @controversy.unity_user_id = nil
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário removido' : 'Erro na remoção de usuário')
    elsif @user.cnes == @controversy.cnes
      @controversy.unity_user = @user
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário adicionado' : 'Erro na adição de usuário')
    else
      redirect_to @controversy, alert: 'Usuário sem permissão para ser adicionado'
    end
  end

  # POST /:id/support_user/:user_id
  def support_user
    @controversy = Controversy.find(params[:id])
    @user = User.find(params[:user_id])

    if !@controversy.support_2.nil?
      @controversy.support_2_user_id = nil
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário removido' : 'Erro na remoção de usuário')
    elsif @user.call_center_user? || @user.call_center_admin? || @user.admin?
      @controversy.support_2 = @user
      redirect_to @controversy,
                  notice: (@controversy.save ? 'Usuário adicionado' : 'Erro na adição de usuário')
    else
      redirect_to @controversy, alert: 'Usuário sem permissão para ser adicionado'
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

  def retrieve_user_creator(parameters)
    puts parameters
    parameters.delete(:user_creator) if parameters[:user_creator]
  end

  def create_controversy(parameters, user_creator_id)
    controversy = Controversy.new(parameters)
    controversy.contract_id = controversy.city.contract.id
    controversy.creator ||= map_role_to_creator
    controversy[controversy.creator + '_user_id'] = user_creator_id || current_user.id
    controversy.support_1_user_id = current_user.id if admin? || support_user?
    controversy
  end

  def map_role_to_creator
    {
      company_user: 'company',
      company_admin: 'company',
      ubs_admin: 'unity',
      ubs_user: 'unity',
      city_admin: 'city',
      call_center_admin: 'support_1',
      call_center_user: 'support_1',
      admin: 'support_1'
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
                                        :support_1_id, :support_2_id, :user_creator, :files)
  end

  def filter_role
    action = params[:action]
    if %w[edit update].include? action
      redirect_to denied_path unless admin?
    elsif %w[new create index destroy].include? action
      redirect_to denied_path unless admin? || support_user? || company_user? ||
                                     city_user? || unity_user?
    elsif action == 'show'
      unless (company_user? && @controversy.company_user_id == current_user.id) ||
             (ubs_user? && @controversy.unity_user_id == current_user.id) ||
             (city_user? && @controversy.unity_user_id == current_user.id) ||
             support_user? ||
             admin?
        redirect_to denied_path
      end
    end
  end
end