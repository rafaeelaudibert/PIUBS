class AnswersController < ApplicationController
  before_action :set_answer, only: %i[show edit update destroy]
  before_action :filter_role, except: %i[faq]
  include ApplicationHelper

  # GET /answers
  # GET /answers.json
  def index
    @answers = Answer.paginate(page: params[:page], per_page: 25)
  end

  # get /faq
  def faq
    @filterrific = initialize_filterrific(
       Answer,
       params[:filterrific],
       select_options: {
         with_category: Category.all.map { |a| [a.name, a.id] },
       },
       :persistence_id => false,
     ) or return
    @answers = Answer.filterrific_find(@filterrific).page(params[:page])
    # @answers = Answer.where('faq = true').order('id DESC').paginate(page: params[:page], per_page: 25)
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
    files = ans_params.delete(:file) if ans_params[:file]
    reply_attachments_ids = params[:reply_attachments].split(',') if params[:reply_attachments]
    @answer = Answer.new(ans_params)

    if @answer.save
      if params[:question_id]
        @call = Call.find(params[:question_id])
        @call.closed!

        # Retira a última answer caso ela não esteja no FAQ, e exclui seus attachment_links
        if @call.answer_id && @call.answer.faq == false
          @oldAnswer = Answer.find(@call.answer_id)
          @oldAnswer.attachment_links.each(&:destroy)

          # Atualiza o answer_id
          @call.answer_id = @answer.id
          AnswerMailer.notify(@call, @answer, current_user).deliver
          raise 'We could not set the call answer_id properly. Please check it' unless @call.save

          # Destroi a anterior
          @oldAnswer.destroy
        else
          # Atualiza o answer_id
          @call.answer_id = @answer.id
          AnswerMailer.notify(@call, @answer, current_user).deliver
          raise 'We could not set the call answer_id properly. Please check it' unless @call.save
        end

      end

      if files
        parsed_params = attachment_params files
        parsed_params[:filename].each_with_index do |_filename, _index|
          @attachment = Attachment.new(eachAttachment(parsed_params, _index))
          raise 'Não consegui anexar o arquivo. Por favor tente mais tarde' unless @attachment.save

          @link = AttachmentLink.new(attachment_id: @attachment.id, answer_id: @answer.id, source: 'answer')
          raise 'Não consegui criar o link entre arquivo e resposta final. Por favor tente mais tarde' unless @link.save
        end
      end

      # "IMPORT" attachments from the reply to this answer
      if reply_attachments_ids
        reply_attachments_ids.each do |_id|
          @link = AttachmentLink.new(attachment_id: _id, answer_id: @answer.id, source: 'answer')
          raise 'Não consegui criar o link entre arquivo que veio da reply e essa resposta. Por favor tente mais tarde' unless @link.save
        end
      end

      redirect_to (@call || faq_path || root_path), notice: 'Final answer was successfully set.'
    else
      render :new
    end
  end

  # PATCH/PUT /answers/1
  # PATCH/PUT /answers/1.json
  def update
    respond_to do |format|
      if @answer.update(answer_params)
        format.html { redirect_to @answer, notice: 'Answer was successfully updated.' }
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
      format.html { redirect_to answers_url, notice: 'Answer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /answers/query/:search
  def search
    respond_to do |format|
      format.js { render json: Answer.where('faq = true').search_for(params[:search]).with_pg_search_rank.limit(15) }
    end
  end

  # GET /answers/attachments/:id
  def attachments
    respond_to do |format|
      format.js { render json: Answer.find(params[:id]).attachments.map { |_attachment| { filename: _attachment.filename, id: _attachment.id } } }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_answer
    @answer = Answer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def answer_params
    params[:answer][:keywords] = params[:answer][:keywords].split(',').join(' ')
    params.require(:answer).permit(:keywords, :question, :answer, :category_id, :user_id, :faq, :question_id, :reply_attachments, file: [])
  end

  ## ATTACHMENTS STUFF
  # Never trust parameters from the scary internet, only allow the white list through.
  def attachment_params(file)
    parameters = {}
    if file
      parameters[:filename] = []
      parameters[:content_type] = []
      parameters[:file_contents] = []
      file.each do |_file|
        parameters[:filename].append(File.basename(_file.original_filename))
        parameters[:content_type].append(_file.content_type)
        parameters[:file_contents].append(_file.read)
      end
    end
    parameters
  end

  def eachAttachment(_parsed_params, _index)
    new_params = {}
    new_params[:filename] = _parsed_params[:filename][_index]
    new_params[:content_type] = _parsed_params[:content_type][_index]
    new_params[:file_contents] = _parsed_params[:file_contents][_index]
    new_params
  end

  def filter_role
    action = params[:action]
    if %w[index edit update].include? action
      redirect_to denied_path unless is_admin?
    elsif %w[new create destroy].include? action
      redirect_to denied_path unless is_admin? || is_support_user?
    elsif action == 'show'
      redirect_to denied_path unless @answer.faq
    end
  end
end
