class ReplyMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.reply_mailer.reply_mailer.subject
  #
  def reply_mailer
    @greeting = 'Hi'

    mail to: 'to@example.org'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.reply_mailer.notification.subject
  #
  def notification(reply, current_user)
    @reply = reply
    @call = Call.find(@reply.protocol)
    @call_user = User.find(@call.user_id)
    @current_user = current_user
    @link = "#{root_url}calls/#{@call.protocol}"

    mail to: @call_user.email
  end
end
