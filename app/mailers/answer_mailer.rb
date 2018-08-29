class AnswerMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.answer_mailer.notification.subject
  #
  def notification(call, answer, current_user)
    @call = call
    @call_user = User.find(@call.user_id)
    @current_user = current_user
    @answer = answer
    @link = "#{root_url}calls/#{@call.protocol}"

    mail to: @call_user.email
  end
end
