class ReplyWorker < ReplyMailer
  include Sidekiq::Worker

  def perform(reply_id, current_user_id, root_url)
    @reply = Reply.find(reply_id)
    @call = Call.find(@reply.protocol)
    @call_user = User.find(@call.user_id)
    @current_user = User.find(current_user_id)
    @link = "#{root_url}calls/#{@call.protocol}"

    mail(to: @call_user.email, subject: "[PIUBS] - Nova resposta ao atendimento #{@reply.protocol}")
    logger.info "Sending reply for #{@call_user.email} for protocol #{@reply.protocol}"
  end
end
