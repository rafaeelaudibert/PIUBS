# frozen_string_literal: true

##
# This is the controller for the Call model
#
# It is responsible for handling the views for any Call
class CallsController < ApplicationController
  include ApplicationHelper

  ##########################
  ## Hooks Configuration ###
  before_action :authenticate_user!
  before_action :restrict_system!
  before_action :filter_role
  before_action :set_company, only: %i[create new]
  before_action :set_call, except: %i[index new create]

  ##########################
  # :section: View methods
  # Method related to generating views

  # Configures the <tt>index</tt> page for the Call model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/apoioaempresas/calls</tt>
  # [GET] <tt>/apoioaempresas/calls.json</tt>
  def index
    (@filterrific = initialize_filterrific(Call, params[:filterrific],
                                           select_options: options_for_filterrific,
                                           persistence_id: false)) || return
    @calls = filtered_calls
  end

  # Configures the <tt>show</tt> page for the Call model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/apoioaempresas/calls/:id</tt>
  # [GET] <tt>/apoioaempresas/calls/:id.json</tt>
  def show
    @answer = Answer.new
    @reply = Reply.new
    @categories = Category.all
    @my_call = @call.support_user == current_user
    @user = User.find(@call.support_user_id) if @call.support_user_id
  end

  # Configures the <tt>new</tt> page for the Call model
  #
  # <b>ROUTES</b>
  #
  # [GET] <tt>/apoioaempresas/calls/new</tt>
  def new
    @call = Call.new
  end

  # Configures the <tt>POST</tt> request to create a new Call
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/apoioaempresas/calls</tt>
  def create
    call_parameters = call_params
    files = retrieve_files call_parameters
    @call = create_call call_parameters

    if @call.save
      create_file_links @call, files
      redirect_to @call, notice: 'Call was successfully created.'
    else
      render :new
    end
  end

  # Configures the <tt>POST</tt> request to link
  # a <tt>support user</tt> to the Call
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/apoioaempresas/calls/:id/link_call_support_user</tt>
  def link_call_support_user
    if @call.support_user
      redirect_back(fallback_location: root_path,
                    alert: 'Você não pode pegar um atendimento de outro usuário do suporte')
    else
      @call.support_user = current_user
      if @call.save
        redirect_back(fallback_location: root_path,
                      notice: 'Agora esse atendimento é seu')
      else
        redirect_back(fallback_location: root_path,
                      notice: 'Ocorreu um erro ao tentar pegar o atendimento')
      end
    end
  end

  # Configures the <tt>POST</tt> request to unlink the
  # <tt>support user</tt> from the Call
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/apoioaempresas/calls/:id/unlink_call_support_user</tt>
  def unlink_call_support_user
    if @call.support_user == current_user
      @call.support_user = nil
      if @call.save
        redirect_back(fallback_location: root_path,
                      notice: 'Atendimento liberado')
      else
        redirect_back(fallback_location: root_path,
                      notice: 'Ocorreu um erro ao tentar liberar o atendimento')
      end
    else
      redirect_back(fallback_location: root_path,
                    alert: 'Esse atendimento pertence a outro usuário do suporte')
    end
  end

  # Configures the <tt>POST</tt> request to reopen a once closed Call
  #
  # <b>ROUTES</b>
  #
  # [POST] <tt>/apoioaempresas/calls/:id/reopen_call</tt>
  def reopen_call
    @answer = @call.answer
    @call = update_call @call, params

    if @call.save
      # Retira a ultima answer caso ela nao esteja no FAQ,
      # e exclui seus attachment_links
      delete_final_answer @answer unless @answer.try(:faq) == true

      redirect_back(fallback_location: root_path, notice: 'Atendimento reaberto')
    else
      redirect_back(fallback_location: root_path,
                    notice: 'Ocorreu um erro ao tentar reabrir o atendimento')
    end
  end

  ##########################
  #### PRIVATE methods #####

  private

  ##########################
  # :section: Hooks methods
  # Methods which are called by the hooks on
  # the top of the file

  # Configures the Company instance when called by
  # the <tt>:before_action</tt> hook
  def set_company
    @company = Company.find(current_user.sei) if current_user.sei
  end

  # Configures the Call instance when called by
  # the <tt>:before_action</tt> hook
  def set_call
    @call = Call.find(params[:id])
  end

  ##########################
  # :section: Filterrific methods
  # Method related to the Filterrific Gem

  # Filterrific method
  #
  # Configures the basic options for the
  # <tt>Filterrific</tt> queries
  def options_for_filterrific
    {
      sorted_by_creation: Call.options_for_sorted_by_creation,
      with_status: Call.options_for_with_status,
      with_state: retrieve_states_for_filterrific,
      with_city: [],
      with_ubs: [],
      with_company: Company.all.map(&:sei)
    }
  end

  # Filterrific method
  #
  # Configures the State instances which can be
  # used to sort the Call instances
  def retrieve_states_for_filterrific
    if current_user.cnes
      State.find(@contracts.map { |c| c.city.state_id }).map { |s| [s.name, s.id] }
    else
      State.all.map { |s| [s.name, s.id] }
    end
  end

  # Filterrific method
  #
  # Returns all the Call instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>support_user</tt> role,
  # which is handled by the calling function
  def calls_from_support_user
    filterrific_query.from_support_user [current_user.id, nil]
  end

  # Filterrific method
  #
  # Returns all the Call instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>support_admin</tt> role,
  # which is handled by the calling function
  def calls_from_support_admin
    filterrific_query.from_support_user [User.where(invited_by_id: current_user.id).map(&:id),
                                         current_user.id,
                                         nil].flatten
  end

  # Filterrific method
  #
  # Returns all the Call instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>company_admin</tt> role,
  # which is handled by the calling function
  def calls_for_company_admin
    filterrific_query.from_company current_user.sei
  end

  # Filterrific method
  #
  # Returns all the Call instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>company_user</tt> role,
  # which is handled by the calling function
  def calls_for_company_user
    filterrific_query.from_company_user current_user.id
  end

  # Filterrific method
  #
  # Returns all the Call instances which the
  # <tt>current_user</tt> can see, knowing he has
  # the <tt>admin</tt> role,
  # which is handled by the calling function
  #
  # OBS: This return all Call instances in the database,
  # but paginated
  def calls_for_admin
    filterrific_query
  end

  ##########################
  # :section: Custom private methods

  # Method called by #reopen_call function,
  # used to reopen a call and re-configure the timeline
  def update_call(call, params)
    call.reopened!
    call.update(reopened_at: 0.seconds.from_now)
    call.answer_id = nil

    Reply.find(params[:reply_id]).update(last_call_ref_reply_reopened_at: 0.seconds.from_now)

    call
  end

  # Checks which are the calls which can be seen by this user
  def filtered_calls
    if support_user?
      current_user.call_center_user? ? calls_from_support_user : calls_from_support_admin
    elsif company_user?
      current_user.company_admin? ? calls_for_company_admin : calls_for_company_user
    elsif admin?
      calls_for_admin
    else
      []
    end
  end

  # Returns a call with the <tt>parameters</tt>
  # received in the request filled, as well as the
  # <tt>user_id</tt> and <tt>sei</tt> fields filled
  def create_call(call_parameters)
    @call = Call.new call_parameters
    @call.user_id ||= current_user.id
    @call.sei ||= current_user.sei

    @call
  end

  # Returns the Attachment instances's ids received in the
  # request, removing it from the parameters
  def retrieve_files(call_parameters)
    call_parameters.delete(:files).split(',') if call_parameters[:files]
  end

  # For each Attachment instance id received in the
  # <tt>files</tt> parameter, creates the AttachmentLink
  # between the Call instance and the Attachment instance.
  def create_file_links(call, files)
    files.each do |file_uuid|
      @link = AttachmentLink.new(attachment_id: file_uuid,
                                 call_id: call.id,
                                 source: 'call')
      unless @link.save
        raise 'Não consegui criar o link entre arquivo e o atendimento.'\
              ' Por favor tente mais tarde'
      end
    end
  end

  # Delete each AttachmentLink for the Answer passed
  # in the <tt>answer</tt> parameter, as well as the
  # own Answer
  def delete_final_answer(answer)
    answer.attachment_links.each(&:destroy)
    answer.destroy # Destroi a resposta final anterior
  end

  # Makes the famous "Never trust parameters from internet, only allow the white list through."
  def call_params
    params.require(:call).permit(:sei, :user_id, :title,
                                 :description, :finished_at, :version,
                                 :access_profile, :feature_detail,
                                 :answer_summary, :severity, :protocol,
                                 :city_id, :category_id, :state_id,
                                 :company_id, :cnes, :files)
  end

  # Restrict the access to the views according to the
  # <tt>current_user system</tt>, as it must have access
  # to the Apoio as Empresas system
  def restrict_system!
    redirect_to denied_path unless current_user.both? || current_user.companies?
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Filters the access to each of the actions of the controller
  def filter_role
    action = params[:action]
    if %w[edit update].include? action
      redirect_to denied_path unless admin?
    elsif %w[new create destroy].include? action
      redirect_to denied_path unless admin_support_company?
    else
      show_or_index?(action)
    end
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Handles the access filter in <tt>show</tt> or <tt>index</tt>
  # actions
  def show_or_index?(action)
    if action == 'show'
      @call ||= Call.try(:find, params[:id]) || Call.try(:find, params[:call])
      redirect_to denied_path unless alloweds_users
    elsif action == 'index'
      redirect_to faq_path unless admin_support_company?
    end
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Handles the access filter for the <tt>show</tt> action
  # in this controller, when called by #show_or_index?
  def alloweds_users
    creator_company_admin? || creator_company_user? || support_user? || admin?
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Verifies if the <tt>current_user</tt> which has
  # a <tt>company_admin</tt> role, has acess to this
  # Call instance
  def creator_company_admin?
    current_user.try(:company_admin?) && @call.sei == current_user.sei
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Verifies if the <tt>current_user</tt> which has
  # a <tt>company_user</tt> role, has acess to this
  # Call instance
  def creator_company_user?
    current_user.try(:company_user?) && @call.user_id == current_user.id
  end

  # <b>DEPRECATED:</b>  Will be replaced by CanCanCan gem
  #
  # Handles the access filter for the <tt>index</tt> action
  # in this controller, when called by #show_or_index?
  def admin_support_company?
    admin? || support_user? || company_user?
  end
end
