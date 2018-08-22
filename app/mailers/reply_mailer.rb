class ReplyMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.reply_mailer.reply_mailer.subject
  #
  def reply_mailer
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.reply_mailer.notification.subject
  #
  def notification(reply)
    @reply = reply
    @greeting = "Olá,"

    # mail to: @reply.email
    mail to: "mario.figueiro@ufrgs.br"
  end
end
