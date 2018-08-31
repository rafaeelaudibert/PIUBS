class AnswerMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.answer_mailer.notification.subject
  #
  def notification(call, answer, current_user)
    @call = call || Call.all.sample
    @call_user = call ? User.find(call.user_id) : User.find(current_user.id)
    @current_user = current_user
    @answer = answer
    @link = call ? "#{root_url}calls/#{call.protocol}" : root_url

    mail to: @call_user.email
  end
end
