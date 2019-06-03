# frozen_string_literal: true

##
# This is the controller for the Answer model
#
# It is responsible for handling the views for any Answer
class AnswersController < ApplicationController
  include ApplicationHelper

  # Hooks Configuration
  before_action :authenticate_user!
  before_action :restrict_system!
  before_action :set_answer, only: %i[show edit update]
  before_action :set_call, only: :create
  before_action :verify_source, only: :new

  # CanCanCan Configuration
  load_and_authorize_resource
  skip_authorize_resource only: %i[faq faq_controversy search_call search_controversy attachments]

  ####
  # :section: View methods
  # Method related to generating views
  ##

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
    @answers = filterrific_query
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
      select_options: { with_category: Category.from_call.map { |a| [a.name, a.id] } },
      persistence_id: false
    )) || return

    @answers = @filterrific.find
                           .faq_from_call
                           .page(params[:page])

    authorize_faq
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
      select_options: { with_category: Category.from_controversy.map { |a| [a.name, a.id] } },
      persistence_id: false
    )) || return

    @answers = @filterrific.find
                           .faq_from_controversy
                           .page(params[:page])

    authorize_faq
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
    @categories = Category.from params[:source]
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
    handle_answer_creation
  rescue Answer::CreateError => e
    render :new, alert: e.message
  rescue Event::CreateError => e
    @answer.delete
    render :new, alert: e.message + 'durante a criação da Resposta Final'
  rescue Alteration::CreateError => e
    @answer.delete # Rollback
    render :new, alert: e.message + 'durante a criação da Resposta Final'
  end

  # Configures the <tt>PATCH/PUT</tt> request to update
  # a Answer
  #
  # <b>ROUTES</b>
  #
  # [PATCH/PUT] <tt>/answers/:id</tt>

  # Check which Links has been removed from Front End by User, returning
  # an Array of Links to be excluded from the database
  def check_removed_links(files)
    links_to_remove = []
    @answer.attachment_links.each do |link|
      unless files.include?(link.attachment_id)
        links_to_remove.push(link)
      end
    end
    links_to_remove
  end

  # Given a Array of Links removes all Links from current answers
  def delete_removed_links(links)
    links.each do |link|
      remove_link(link)
    end
  end

  # Updates current answer with a given list of parameters
  def update
    files = retrieve_files_from params[:answer][:files]
    links_to_remove = check_removed_links(files)
    if @answer.update(answer_params)
      delete_removed_links(links_to_remove)
      create_file_links @answer, files
      redirect_to @answer, notice: 'Resposta atualizada com sucesso.'
    else
      render :edit
    end
  end

  # Given a single Link, removes Link reference from current answer
  def remove_link(link)
    attachment_link = AttachmentLink.find(link.id)
    attachment = attachment_link.attachment
    if attachment_link.delete
      @answer.attachment_links.delete(link)
    end
    attachment.delete if attachment.attachment_links.length == 0
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
    authorize! :query_faq, Answer
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
    authorize! :query_faq, Answer
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
    @answer = Answer.find(params[:id])
    authorize! :show, @answer

    @attachments = @answer.attachments
                          .map do |attachment|
      { filename: attachment.filename,
        type: attachment.content_type,
        id: attachment.id,
        bytes: retrieve_file_bytes(attachment) }
    end
  end

  private

  ####
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file
  ##

  # Configures the Answer instance when called by
  # the <tt>:before_action</tt> hook
  def set_answer
    @answer = Answer.find(params[:id])
  end

  # Configures the Call instance when called by
  # the <tt>:before_action</tt> hook for #create method
  def set_call
    @call = Call.find(params[:call_id]) if params[:call_id]
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
  def verify_source
    redirect_to not_found_path unless %w[call controversy].include?(params[:source])
  end

  ##########################
  # :section: Custom private methods

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def answer_params
    params[:answer][:keywords] = params[:answer][:keywords].split(',').join(' ; ')
    params.require(:answer).permit(:keywords, :question, :answer, :category_id,
                                   :user_id, :faq, :call_id, :system_id, :reply_attachments)
  end

  # When called by #create, handles the possible change
  # of Final Answer in the possible Call parent instance
  # as well as removing the old Answer which occupied that place
  def mark_as_final_answer(answer)
    update_call @call

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

  # Called by #handle_answer_creation, parses the String passed as
  # parameter to the Answer creation, to be able to create
  # the AttachmentLinks later
  def retrieve_files_from(files)
    files != '' ? files.split(',') : []
  end

  # Called by #create, handles all the Answer creation proccess
  def handle_answer_creation
    files = retrieve_files_from params[:answer][:files]
    @answer = Answer.new(answer_params)
    raise Answer::CreateError unless @answer.save
    mark_as_final_answer @answer if params[:call_id]
    create_file_links @answer, files

    # Answer created from a call or from the FAQ
    check_create_redirect
  end

  # Called by #mark_as_final_answer, handles the need to close
  # the Answer's Call parent instance, as well as handling the
  # timeline of it
  def update_call(call)
    # Create event
    @event = Event.new(type: EventType.alteration,
                       user: current_user,
                       system: System.call,
                       protocol: call.protocol)

    raise Event::CreateError, @event.errors.inspect unless @event.save

    # After we correctly saved the event
    @alteration = Alteration.new(id: @event.id, type: :close_call)
    raise Alteration::CreateError, event: @event unless @alteration.save

    call.close!
  end

  # Called by #mark_as_final_answer, updates the <tt>answer</tt>
  # field in the Answer's Call parent instance to reference it,
  # as well as sending an e-mail telling about the Call close.
  def update_answer_id(call, answer)
    call.answer_id = answer.id
    raise 'Não conseguimos salvar a answer de maneira correta.' unless call.save

    AnswerMailer.new_answer(call, answer, current_user).deliver_later
  end

  def current_attachments
    @current_attachments = []
    @answer.attachment_links.each do |link|
      @current_attachments.push(link.attachment_id)
    end
    @current_attachments
  end

  # For each Attachment instance id received in the
  # <tt>files</tt> parameter, creates the AttachmentLink
  # between the Answer instance and the Attachment instance.
  def create_file_links(answer, files)
      current_attachments
      files.each do |file_uuid|
        unless @current_attachments.include?(file_uuid)
          @link = AttachmentLink.new(attachment_id: file_uuid,
                                     answer_id: answer.id,
                                     source: 'answer')
          unless @link.save
            raise 'Não consegui criar o link entre arquivo e resposta final.'\
                  ' Por favor tente mais tarde'
          end
        end
      end
  end

  # Called by #attachments, query the database to know
  # what is the size in bytes of the Attachment instance
  # passed as parameter
  def retrieve_file_bytes(attachment)
    Answer.connection
          .select_all(Answer.sanitize_sql_array([
                                                  'SELECT octet_length("BL_CONTEUDO") FROM '\
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

  ####
  # :section: CanCanCan methods
  # Methods which are related to the CanCanCan gem
  ##

  # CanCanCan Method
  #
  # Default CanCanCan Method, declaring the AnswerAbility
  def current_ability
    @current_ability ||= AnswerAbility.new(current_user)
  end

  # CanCanCan Method
  #
  # Method called by the FAQ-like views, to authorize which Answers can be seen
  def authorize_faq
    # We use the first, to bypass CanCanCan problems
    authorize! :read, @answers.first unless @answers.empty?
  end
end
