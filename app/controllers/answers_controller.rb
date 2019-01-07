# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :restrict_system!
  before_action :set_answer, only: %i[show edit update]
  before_action :filter_role
  before_action :verify_source, only: :new
  include ApplicationHelper

  # GET /answers
  # GET /answers.json
  def index
    (@filterrific = initialize_filterrific(
      Answer,
      params[:filterrific],
      select_options: { # em breve
      },
      persistence_id: false
    )) || return
    @answers = @filterrific.find
                           .joins(:category)
                           .order('categories.name', :question, :answer)
                           .page(params[:page])
  end

  # get /faq
  def faq
    (@filterrific = initialize_filterrific(
      Answer,
      params[:filterrific],
      select_options: {
        with_category: Category.where(source: :from_call).map { |a| [a.name, a.id] }
      },
      persistence_id: false
    )) || return

    @answers = Answer.where(faq: true, source: :from_call)
                     .filterrific_find(@filterrific)
                     .joins(:category)
                     .order('categories.name', :question, :answer)
                     .page(params[:page])
  end

  # get /faq_controversy
  def faq_controversy
    (@filterrific = initialize_filterrific(
      Answer,
      params[:filterrific],
      select_options: {
        with_category: Category.where(source: :from_controversy).map { |a| [a.name, a.id] }
      },
      persistence_id: false
    )) || return

    @answers = Answer.where(faq: true, source: :from_controversy)
                     .filterrific_find(@filterrific)
                     .joins(:category)
                     .order('categories.name', :question, :answer)
                     .page(params[:page])
  end

  # GET /answers/1
  def show; end

  # GET /answers/new
  def new
    @answer = Answer.new
    @reply = Reply.find(params[:reply]) if params[:reply]
    @question = Call.find(params[:question]) if params[:question]
    @categories = Category.where(source: params[:source] == 'call' ? :from_call : :from_controversy)
  end

  # GET /answers/1/edit
  def edit
    @categories = Category.where(source: (@answer.from_call? ? :from_call : :from_controversy))
  end

  # POST /answers
  def create
    files = retrieve_files(params) || []

    @answer = Answer.new(answer_params)
    @call = Call.find(params[:call_id])
    if @answer.save
      mark_as_final_answer @answer if params[:call_id]
      create_file_links @answer, files

      # Answer created from a call or from the FAQ
      check_create_redirect
    else
      render :new
    end
  end

  # PATCH/PUT /answers/1
  # PATCH/PUT /answers/1.json
  def update
    ans_params = answer_params
    files = retrieve_files ans_params

    if @answer.update(ans_params)

      # Remove do DB os links que foram removidos do front_end
      @answer.attachment_links.each { |link| remove_link(link, files) unless files.include?(link) }

      create_file_links @answer, files
      redirect_to @answer, notice: 'Resposta atualizada com sucesso.'
    else
      render :edit
    end
  end

  # GET /answers/query_call/:search
  def search_call
    @answers = Answer.faq_from_call
                     .search_for(params[:search])
                     .with_pg_search_rank
                     .limit(15)
  end

  # GET /answers/query_controversy/:search
  def search_controversy
    @answers = Answer.faq_from_controversy
                     .search_for(params[:search])
                     .with_pg_search_rank
                     .limit(15)
  end

  # GET /answers/attachments/:id
  def attachments
    respond_to do |format|
      format.js do
        render(json: Answer.find(params[:id])
                                      .attachments
                                      .map do |attachment|
                       { filename: attachment.filename,
                         type: attachment.content_type,
                         id: attachment.id,
                         bytes: retrieve_file_bytes(attachment) }
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
    normalize_params
    params.require(:answer).permit(:keywords, :question, :answer, :category_id,
                                   :user_id, :faq, :call_id, :source,
                                   :reply_attachments)
  end

  def normalize_params
    params[:answer][:keywords] = params[:answer][:keywords].split(',').join(' ; ')
    params[:answer][:faq] = params[:answer][:faq].to_i == 1 ? 'S' : 'N'
  end

  def retrieve_files(ans_params)
    ans_params.delete(:files).split(',') if ans_params[:files]
  end

  def mark_as_final_answer(answer)
    update_call_reply @call

    # Retira a answer caso ela nao esteja no FAQ + attach_links
    if @call.answer.try(:faq) == false
      @old_answer = Answer.find(@call.answer_id)
      @old_answer.attachment_links.each(&:destroy)

      update_answer_id @call, answer
      @old_answer.destroy
    else
      update_answer_id @call, answer
    end
  end

  def update_call_reply(call)
    call.update(TP_STATUS: 'closed', DT_FINALIZADO_EM: 0.seconds.from_now)
    call.replies.first.update(DT_REF_ATENDIMENTO_FECHADO: 0.seconds.from_now)
  end

  def update_answer_id(call, answer)
    call.answer_id = answer.id
    raise 'Não conseguimos salvar a answer de maneira correta.' unless call.save

    AnswerMailer.new_answer(call, answer, current_user).deliver_later
  end

  def create_file_links(answer, files)
    files.each do |file_uuid|
      @link = AttachmentLink.new(attachment_id: file_uuid,
                                 answer_id: answer.id,
                                 source: 'answer')
      unless @link.save
        raise 'Não consegui criar o link entre arquivo e resposta final.'\
              ' Por favor tente mais tarde'
      end
    end
  end

  def remove_links(link, files)
    link.destroy
    files.delete(link)
  end

  def retrieve_file_bytes(attachment)
    Answer.connection
          .select_all(Answer.sanitize_sql_array([
                                                  'SELECT octet_length(file_contents) FROM '\
                                                  'attachments WHERE attachments.id = ?',
                                                  attachment.id
                                                ]))[0]['octet_length']
  end

  def restrict_system!
    redirect_to denied_path if params[:action] == 'faq' && current_user.controversies?
    redirect_to denied_path if params[:action] == 'faq_controversy' && current_user.companies?
  end

  def filter_role
    action = params[:action]
    if %w[index edit update].include? action
      redirect_to denied_path unless admin? || faq_inserter?
    elsif %w[new create destroy].include? action
      redirect_to denied_path unless admin_support_faq?
    else
      show?(action)
    end
  end

  def verify_source
    redirect_to not_found_path unless %w[call controversy].include?(params[:source])
  end

  def admin_support_faq?
    admin? || support_user? || faq_inserter?
  end

  def show?(action)
    redirect_to denied_path if action == 'show' && !alloweds_users_to_show?
  end

  def alloweds_users_to_show?
    faq_and_not_city_ubs_users? || admin? || faq_inserter? || support_and_answer_creator?
  end

  def faq_and_not_city_ubs_users?
    @answer.faq && !city_user? && !ubs_user?
  end

  def support_and_answer_creator?
    support_user? && @answer.user_id == current_user.id
  end

  def check_create_redirect
    if @call
      redirect_to @call, notice: 'Resposta final marcada com sucesso' if @call
    else
      redirect_to @answer || root_path, notice: 'Questão criada com sucesso.'
    end
  end
end
