# frozen_string_literal: true

##
# This is the mailer for the Reply model
class ReplyMailer < ApplicationMailer
  # Sends an e-mail to the <tt>company_user</tt>
  # involved in the Call instance related to the Reply
  # passed as a parameter, informing that there is a new
  # Reply in his Call
  def call_reply(reply, current_user)
    @reply = reply
    @call = Call.find(@reply.repliable.id)
    @call_user = User.find(@call.user_id)
    @current_user = current_user
    @link = "#{root_url}calls/#{@call.protocol}"

    mail to: @call_user.email,
         subject: "[PIUBS] - Nova resposta ao atendimento #{@reply.repliable.id}"
  end

  # Sends an e-mail to the User passed as a parameter,
  # which involved in the Controversy instance related to the Reply
  # passed as a parameter, informing that there is a new
  # Reply in the Controversy
  def controversy_reply(reply, current_user, user)
    @reply = reply
    @controversy = Controversy.find(@reply.repliable.id)
    @current_user = current_user
    @link = "#{root_url}controversies/#{@controversy.protocol}"
    @user = user

    mail to: @user.email,
         subject: "[PIUBS] - Nova resposta à controvérsia #{@reply.repliable.id}"
  end
end
