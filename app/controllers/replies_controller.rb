class RepliesController < ApplicationController
  before_action :set_reply, only: %i[show edit update destroy]

  # GET /replies
  def index
    @replies = Reply.paginate(page: params[:page], per_page: 25)
  end

  # GET /replies/1
  def show; end

  # GET /replies/new
  def new
    @reply = Reply.new
  end

  # GET /replies/1/edit
  def edit; end

  # POST /replies
  def create
    @reply = Reply.new(reply_params)
    @reply.user_id = current_user.id
    @reply.category = is_support_user ? 'support' : 'reply'
    if @reply.save
      redirect_to call_path(@reply.protocol), notice: 'Reply was successfully created.'
      ReplyMailer.notification(@reply, current_user).deliver
    else
      render :new
    end
  end

  # PATCH/PUT /replies/1
  def update
    if @reply.update(reply_params)
      redirect_to @reply, notice: 'Reply was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /replies/1
  def destroy
    @reply.destroy
    redirect_to replies_url, notice: 'Reply was successfully destroyed.'
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
