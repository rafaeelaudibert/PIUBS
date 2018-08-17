class AnswersController < ApplicationController
  before_action :set_answer, only: %i[show edit update destroy]

  # GET /answers
  # GET /answers.json
  def index
    @answers = Answer.where('faq = true')
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
    @answer = Answer.new(answer_params)

    respond_to do |format|
      if @answer.save
        @call = Call.find(params[:question_id])
        @call.answer_id = @answer.id
        raise 'We could not set the call answer_id properly. Please check it' unless @call.save
        format.html { redirect_to @answer, notice: 'Answer was successfully created.' }
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
    params.require(:answer).permit(:question, :answer, :category_id, :user_id, :faq, :question_id)
  end
end
