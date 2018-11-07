# frozen_string_literal: true

class ReplyMailer < ApplicationMailer
  def call_reply(reply, current_user)
    @reply = reply
    @call = Call.find(@reply.repliable_id)
    @call_user = User.find(@call.user_id)
    @current_user = current_user
    @link = "#{root_url}calls/#{@call.protocol}"

    mail to: @call_user.email,
         subject: "[PIUBS] - Nova resposta ao atendimento #{@reply.repliable_id}"
  end

  def controversy_reply(reply, current_user, user)
    @reply = reply
    @controversy = Controversy.find(@reply.repliable_id)
    @current_user = current_user
    @link = "#{root_url}controversies/#{@controversy.protocol}"
    @user = user

    mail to: @user.email,
         subject: "[PIUBS] - Nova resposta à controvérsia #{@reply.repliable_id}"
  end
end
