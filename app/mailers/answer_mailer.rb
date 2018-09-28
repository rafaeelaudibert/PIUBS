# frozen_string_literal: true

class AnswerMailer < ApplicationMailer
  def notify(call, answer, current_user)
    @call = call || Call.all.sample
    @call_user = call ? User.find(call.user_id) : User.find(current_user.id)
    @current_user = current_user
    @answer = answer
    @link = call ? "#{root_url}calls/#{call.protocol}" : root_url

    mail(to: @call_user.email, subject: "[PIUBS] - Resposta final para o atendimento #{@call.protocol}")
  end
end
