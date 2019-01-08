# frozen_string_literal: true

##
# This is the mailer for the Call model
class CallMailer < ApplicationMailer
  # Sends an e-mail to the <tt>company_user</tt> envolved
  # in the Call, when a new Call is created
  def new_call(call, current_user)
    @call = call
    @current_user = current_user
    @link = "#{root_url}calls/#{@call.protocol}"

    mail to: @current_user.email,
         subject: "[PIUBS] - Criação do atendimento #{@call.protocol}"
  end
end
