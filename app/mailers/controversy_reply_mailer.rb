# frozen_string_literal: true

class ControversyReplyMailer < ApplicationMailer
  def notify(reply, current_user, user)
    @reply = reply
    @controversy = Controversy.find(@reply.repliable_id)
    @current_user = current_user
    @link = "#{root_url}controversies/#{@controversy.protocol}"
    @user = user

    mail to: @user.email,
         subject: "[PIUBS] - Nova resposta à controvérsia #{@reply.repliable_id}"
  end
end
