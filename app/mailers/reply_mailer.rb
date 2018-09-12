class ReplyMailer < ApplicationMailer
  def notify(reply, current_user)
    @reply = reply
    @call = Call.find(@reply.protocol)
    @call_user = User.find(@call.user_id)
    @current_user = current_user
    @link = "#{root_url}calls/#{@call.protocol}"

    mail(to: @call_user.email, subject: "[PIUBS] - Nova resposta ao atendimento #{@reply.protocol}")
  end
end
