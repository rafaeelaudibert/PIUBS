class RepliesController < ApplicationController
  before_action :set_reply, only: %i[show edit update destroy]

  # GET /replies
  # GET /replies.json
  def index
    @replies = Reply.paginate(page: params[:page], per_page: 25)
  end

  # GET /replies/1
  # GET /replies/1.json
  def show; end

  # GET /replies/new
  def new
    @reply = Reply.new
  end

  # GET /replies/1/edit
  def edit; end

  # POST /replies
  # POST /replies.json
  def create
    @reply = Reply.new(reply_params)
    @reply.user_id = current_user.id
    @reply.category = if is_support_user
                        'support'
                      else
                        'reply'
                      end

    respond_to do |format|
      if @reply.save
        format.html { redirect_to call_path(@reply.protocol), notice: 'Reply was successfully created.' }
        format.json { render :show, status: :created, location: @reply }
        ReplyMailer.notification(@reply, current_user).deliver
      else
        format.html { render :new }
        format.json { render json: @reply.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /replies/1
  # PATCH/PUT /replies/1.json
  def update
    respond_to do |format|
      if @reply.update(reply_params)
        format.html { redirect_to @reply, notice: 'Reply was successfully updated.' }
        format.json { render :show, status: :ok, location: @reply }
      else
        format.html { render :edit }
        format.json { render json: @reply.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /replies/1
  # DELETE /replies/1.json
  def destroy
    @reply.destroy
    respond_to do |format|
      format.html { redirect_to replies_url, notice: 'Reply was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_reply
    @reply = Reply.find(params[:id])
  end

  def is_company_user
    current_user.try(:company_user?) || current_user.try(:company_admin?)
  end

  def is_support_user
    current_user.try(:call_center_user?) || current_user.try(:call_center_admin?)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def reply_params
    params.require(:reply).permit(:protocol, :description, :user_id, :status, :faq)
  end
end
