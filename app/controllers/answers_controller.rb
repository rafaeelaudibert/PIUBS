class AnswersController < ApplicationController
  before_action :set_answer, only: %i[show edit update destroy]

  # GET /answers
  # GET /answers.json
  def index
    @answers = Answer.where('faq = true').paginate(page: params[:page], per_page: 25)
  end

  # GET /answers/1
  # GET /answers/1.json
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
  # POST /answers.json
  def create
    ans_params = answer_params
    files = ans_params.delete(:file) if ans_params[:file]
    @answer = Answer.new(ans_params)
    respond_to do |format|
      if @answer.save
        if params[:question_id]
          @call = Call.find(params[:question_id])
          @call.answer_id = @answer.id
          raise 'We could not set the call answer_id properly. Please check it' unless @call.save
        end
        if files
          parsed_params = attachment_params files
          parsed_params[:filename].each_with_index do |_filename, _index|
            @attachment = Attachment.new(eachAttachment(parsed_params, _index, @answer.id))
            raise 'Não consegui anexar o arquivo. Por favor tente mais tarde' unless @attachment.save
          end
        end
        format.html { redirect_to @call, notice: 'Final answer was successfully marked.' }
        format.json { render :show, status: :created, location: @answer }
      else
        format.html { render :new }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
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
      format.js { render json: Answer.where('faq = true').search_for(params[:search]).with_pg_search_rank }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_answer
    @answer = Answer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def answer_params
    params.require(:answer).permit(:question, :answer, :category_id, :user_id, :faq, :question_id, file: [])
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

  def eachAttachment(_parsed_params, _index, _answer)
    new_params = {}
    new_params[:filename] = _parsed_params[:filename][_index]
    new_params[:content_type] = _parsed_params[:content_type][_index]
    new_params[:file_contents] = _parsed_params[:file_contents][_index]
    new_params[:answer_id] = _answer
    new_params
  end
end
