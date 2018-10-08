# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :set_answer, only: %i[show edit update destroy]
  before_action :filter_role, except: %i[faq]
  include ApplicationHelper

  # GET /answers
  # GET /answers.json
  def index
    @answers = Answer.order('category_id ASC').paginate(page: params[:page], per_page: 25)
  end

  # get /faq
  def faq
    (@filterrific = initialize_filterrific(
      Answer,
      params[:filterrific],
      select_options: {
        with_category: Category.all.map { |a| [a.name, a.id] }
      },
      persistence_id: false
    )) || return
    @answers = Answer.filterrific_find(@filterrific).includes(:category).page(params[:page])

    # As linha abaixo sao backup do que tinha antes de add o filterrific
    # @answers = Answer.where(faq: true).includes(:category)
    # .order('category_id ASC').paginate(page: params[:page], per_page: 25)

    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /answers/1
  def show; end

  # GET /answers/new
  def new
    @answer = Answer.new
    @reply = Reply.find(params[:reply]) if params[:reply]
    @question = Call.find(params[:question]) if params[:question]
  end

  # GET /answers/1/edit
  def edit; end

  # POST /answers
  def create
    ans_params = answer_params
    puts ans_params
    files = ans_params.delete(:files).split(',') if ans_params[:files]
    puts '---------------------'
    puts files
    @answer = Answer.new(ans_params)

    if @answer.save
      if params[:question_id]
        @call = Call.find(params[:question_id])
        @call.closed!

        # Retira a answer caso ela nao esteja no FAQ + attach_links
        if @call.answer_id && @call.answer.faq == false
          @old_answer = Answer.find(@call.answer_id)
          @old_answer.attachment_links.each(&:destroy)

          # Atualiza o answer_id
          @call.answer_id = @answer.id
          AnswerMailer.notify(@call, @answer, current_user).deliver_later
          raise 'Não conseguimos salvar a answer de maneira correta.' unless @call.save

          # Destroi a anterior
          @old_answer.destroy
        else
          # Atualiza o answer_id
          @call.answer_id = @answer.id
          AnswerMailer.notify(@call, @answer, current_user).deliver_later
          raise 'Não conseguimos salvar a answer de maneira correta.' unless @call.save
        end

      end

      puts '-----------------------------------'
      puts files
      if files
        files.each do |file_uuid|
          @link = AttachmentLink.new(attachment_id: file_uuid,
                                     answer_id: @answer.id,
                                     source: 'answer')
          unless @link.save
             raise 'Não consegui criar o link entre arquivo e resposta final.'\
                   ' Por favor tente mais tarde'
          end
        end
      end

      # "IMPORT" attachments from the reply to this answer
      # Commented while creating new attachments drag n' drop with dragzone.js - RBAUDIBERT @ 09/10/2018

      # reply_attachments_ids&.each do |id|
      #   @link = AttachmentLink.new(attachment_id: id, answer_id: @answer.id, source: 'answer')
      #   unless @link.save
      #     raise 'Não consegui criar o link entre arquivo que veio da reply e essa resposta.'\
      #           ' Por favor tente mais tarde'
      #   end
      # end

      redirect_to (@call || faq_path || root_path), notice: 'Resposta final marcada com sucesso.'
    else
      render :new
    end
  end

  # PATCH/PUT /answers/1
  # PATCH/PUT /answers/1.json
  def update
    respond_to do |format|
      if @answer.update(answer_params)
        format.html { redirect_to @answer, notice: 'Resposta atualizada com sucesso.' }
        format.json { render :show, status: :ok, location: @answer }
      else
        format.html { render :edit }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /answers/1
  # DELETE /answers/1.json
  def destroy
    @answer.destroy
    respond_to do |format|
      format.html { redirect_to answers_url, notice: 'Resposta excluída com sucesso.' }
      format.json { head :no_content }
    end
  end

  # GET /answers/query/:search
  def search
    respond_to do |format|
      format.js do
        render json: Answer.where('faq = true')
                           .search_for(params[:search])
          .with_pg_search_rank.limit(15)
      end
    end
  end

  # GET /answers/attachments/:id
  def attachments
    respond_to do |format|
      format.js do
        render(json: Answer.find(params[:id])
                                      .attachments
                                      .map do |attachment|
                       { filename: attachment.filename,
                         id: attachment.id }
                     end)
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_answer
    @answer = Answer.find(params[:id])
  end

  # Never trust parameters from internet, only allow the white list through.
  def answer_params
    puts params
    params[:answer][:keywords] = params[:answer][:keywords].split(',').join(' ; ')
    params.require(:answer).permit(:keywords, :question, :answer, :category_id,
                                   :user_id, :faq, :question_id,
                                   :reply_attachments, :files)
  end

  def filter_role
    action = params[:action]
    if %w[index edit update].include? action
      redirect_to denied_path unless admin? || faq_inserter?
    elsif %w[new create destroy].include? action
      redirect_to denied_path unless admin? || support_user? || faq_inserter?
    elsif action == 'show'
      unless @answer.faq ||
             admin? ||
             (support_user? && @answer.user_id == current_user.id) ||
             faq_inserter?
        redirect_to denied_path
      end
    end
  end
end
