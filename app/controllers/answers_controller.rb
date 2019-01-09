# frozen_string_literal: true

##
# This is the controller for the Answer model
#
# It is responsible for handling the views for any Answer
class AnswersController < ApplicationController
  include ApplicationHelper

  ##########################
  ## Hooks Configuration ###

  before_action :authenticate_user!
  before_action :restrict_system!
  before_action :set_answer, only: %i[show edit update]
  before_action :filter_role
  before_action :check_new_params, only: :new

  ##########################
  # :section: View methods
  # Method related to generating views

  # Configures the <tt>index</tt> page for the Answer model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/answers</tt>
  # [GET] <tt>/answers.json</tt>
  def index
    (@filterrific = initialize_filterrific(
      Answer,
      params[:filterrific],
      persistence_id: false
    )) || return
    @answers = @filterrific.find.page(params[:page])
  end

  # Configures the <tt>faq</tt> page for the Answer model
  #
  # This FAQ is related to the Apoio as Empresas system
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/apoioaempresas/faq</tt>
  # [GET] <tt>/apoioaempresas/faq.json</tt>
  def faq
    (@filterrific = initialize_filterrific(
      Answer,
      params[:filterrific],
      select_options: {
        with_category: Category.from_call.map { |a| [a.name, a.id] }
      },
      persistence_id: false
    )) || return

    @answers = @filterrific.find
                           .faq_from_call
                           .page(params[:page])
  end

  # Configures the <tt>faq</tt> page for the Answer model
  #
  # This FAQ is related to the Solucao de Controversias system
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/controversias/faq</tt>
  # [GET] <tt>/controversias/faq.json</tt>
  def faq_controversy
    (@filterrific = initialize_filterrific(
      Answer,
      params[:filterrific],
      select_options: {
        with_category: Category.from_controversy.map { |a| [a.name, a.id] }
      },
      persistence_id: false
    )) || return

    @answers = @filterrific.find
                           .faq_from_controversy
                           .page(params[:page])
  end

  # Configures the <tt>show</tt> page for the Answer model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/answers/:id</tt>
  # [GET] <tt>/answers/:id.json</tt>
  def show; end

  # Configures the <tt>new</tt> page for the Answer model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/answers/new</tt>
  def new
    @answer = Answer.new
    @reply = Reply.find(params[:reply]) if params[:reply]
    @question = Call.find(params[:question]) if params[:question]
    @categories = Category.where(source: params[:source] == 'call' ? :from_call : :from_controversy)
  end

  # Configures the <tt>edit</tt> page for the Answer model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/answers/:id/edit</tt>
  def edit
    @categories = @answer.from_call? ? Category.from_call : Category.from_controversy
  end

  # Configures the <tt>POST</tt> request to create a new Answer
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/answers</tt>
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

  # Configures the <tt>PATCH/PUT</tt> request to update
  # a Answer
  #
  # <b>ROUTES</b>
  #
  # [PATCH/PUT] <tt>/answers/:id</tt>
  def update
    files = retrieve_files(params) || []

    if @answer.update(answer_params)

      # Remove do DB os links que foram removidos do front_end
      @answer.attachment_links.each { |link| remove_link(link, files) unless files.include?(link) }

      create_file_links @answer, files
      redirect_to @answer, notice: 'Resposta atualizada com sucesso.'
    else
      render :edit
    end
  end

  # Configures the <tt>query_call</tt> page for
  # the Answer model. This makes a PG_SEARCH in the database
  # returning the result ordered from the "best" to the "worst"
  # in the Answer instances which are in the FAQ for
  # the Call model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/answers/query_call/:search</tt>
  # [GET] <tt>/answers/query_call/:search.json</tt>
  def search_call
    @answers = Answer.search_query_faq_call(params[:search])
                     .with_pg_search_rank
                     .limit(15)
  end

  # Configures the <tt>query_controversy</tt> page for
  # the Answer model. This makes a PG_SEARCH in the database
  # returning the result ordered from the "best" to the "worst"
  # in the Answer instances which are in the FAQ for
  # the Controversy model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/answers/query_controversy/:search</tt>
  # [GET] <tt>/answers/query_controversy/:search.json</tt>
  def search_controversy
    @answers = Answer.search_query_faq_controversy(params[:search])
                     .with_pg_search_rank
                     .limit(15)
  end

  # Configures the <tt>attachments</tt> request for the
  # Answer model. It returns all Attachment instances which
  # belongs to the queried Answer
  #
  # <b>OBS.:</b> This view only exist in a JSON format
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/answers/:id/attachments.json</tt>
  def attachments
    @attachments = Answer.find(params[:id])
                         .attachments
                         .map do |attachment|
      { filename: attachment.filename,
        type: attachment.content_type,
        id: attachment.id,
        bytes: retrieve_file_bytes(attachment) }
    end
  end

  private

  ##########################
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file

  # Configures the Company instance when called by
  # the <tt>:before_action</tt> hook
  def set_answer
    @answer = Answer.find(params[:id])
  end

  # Restrict the access to the views according to the
  # <tt>current_user system</tt>, as some views can only be
  # acessed by some <tt>system</tt> allowed users.
  # This method is called by a <tt>:before_action</tt> hook
  def restrict_system!
    redirect_to denied_path if params[:action] == 'faq' && current_user.controversies?
    redirect_to denied_path if params[:action] == 'faq_controversy' && current_user.companies?
  end

  # Verifies if the required params <tt>:source</tt> was
  # passed when calling the #new method.
  # This method is called by a <tt>:before_action</tt> hook
  def check_new_params
    redirect_to not_found_path unless %w[call controversy].include?(params[:source])
  end

  ##########################
  # :section: Custom private methods

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def answer_params
    normalize_params
    params.require(:answer).permit(:keywords, :question, :answer, :category_id,
                                   :user_id, :faq, :call_id, :source,
                                   :reply_attachments)
  end

  # Called by #answer_params to normalize the <tt>keywords</tt>
  # and the <tt>faq</tt> fields
  def normalize_params
    params[:answer][:keywords] = params[:answer][:keywords].split(',').join(' ; ')
    params[:answer][:faq] = params[:answer][:faq].to_i == 1 ? 'S' : 'N'
  end

  # Returns the Attachment instances's ids received in the
  # request, removing it from the parameters
  def retrieve_files(ans_params)
    ans_params.delete(:files).split(',') if ans_params[:files]
  end

  # When called by #create, handles the possible change
  # of Final Answer in the possible Call parent instance
  # as well as removing the old Answer which occupied that place
  def mark_as_final_answer(answer)
    update_call_reply @call

    # Removes the old answer if he is not in the FAQ and
    # remove its AttachmentLink instances
    if @call.answer.try(:faq) == false
      old_answer = Answer.find(@call.answer_id)
      old_answer.attachment_links.each(&:destroy)

      update_answer_id @call, answer
      old_answer.destroy
    else
      update_answer_id @call, answer
    end
  end

  # Called by #mark_as_final_answer, handles the need to close
  # the Answer's Call parent instance, as well as handling the
  # timeline of it
  def update_call_reply(call)
    call.update(TP_STATUS: 'closed', DT_FINALIZADO_EM: 0.seconds.from_now)
    call.replies.first.update(DT_REF_ATENDIMENTO_FECHADO: 0.seconds.from_now)
  end

  # Called by #mark_as_final_answer, updates the <tt>answer</tt>
  # field in the Answer's Call parent instance to reference it,
  # as well as sending an e-mail telling about the Call close.
  def update_answer_id(call, answer)
    call.answer_id = answer.id
    raise 'Não conseguimos salvar a answer de maneira correta.' unless call.save

    AnswerMailer.new_answer(call, answer, current_user).deliver_later
  end

  # For each Attachment instance id received in the
  # <tt>files</tt> parameter, creates the AttachmentLink
  # between the Answerr instance and the Attachment instance.
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

  # Called by #attachments, query the database to know
  # what is the size in bytes of the Attachment instance
  # passed as parameter
  def retrieve_file_bytes(attachment)
    Answer.connection
          .select_all(Answer.sanitize_sql_array([
                                                  'SELECT octet_length(file_contents) FROM '\
                                                  '"TB_ANEXO" WHERE "TB_ANEXO"."CO_ID" = ?',
                                                  attachment.id
                                                ]))[0]['octet_length']
  end

  # Called after #create, verifies if we should redirect to a
  # Call instance view or to the own Answer instance view
  def check_create_redirect
    if @call
      redirect_to @call, notice: 'Resposta final marcada com sucesso' if @call
    else
      redirect_to @answer || root_path, notice: 'Questão criada com sucesso.'
    end
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Filters the access to each of the actions of the controller
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

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Called by #filter_role, verifies if the user has one
  # of the following roles:
  # <tt>admin</tt>, <tt>call_center_user</tt>,
  # <tt>call_center_admin</tt> or <tt>faq_inserter</tt>
  def admin_support_faq?
    admin? || support_user? || faq_inserter?
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Called by #filter_role, verifies that, knowing that the current action
  # is <tt>show</t>, only allowed users are trying to see it
  def show?(action)
    redirect_to denied_path if action == 'show' && !alloweds_users_to_show?
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Called by #show? returns a boolean saying if the <tt>current_user</tt>
  # is allowed to see this Answer instance
  def alloweds_users_to_show?
    faq_and_not_city_ubs_users? || admin? || faq_inserter? || support_and_answer_creator?
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Called by #allowed_users_to_show? returns true if the
  # Answer instance is on FAQ, but the <tt>current_user</tt> shouldn't
  # belong to a City or a Unity instance
  def faq_and_not_city_ubs_users?
    @answer.faq && !city_user? && !ubs_user?
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Called by #allowed_users_to_show? returns true if the
  # <tt>current_user</tt> is from the support and he was
  # the creator of the Answer
  def support_and_answer_creator?
    support_user? && @answer.user_id == current_user.id
  end
end
