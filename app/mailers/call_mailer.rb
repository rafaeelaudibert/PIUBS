class CallMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.call_mailer.notification.subject
  #
  def notification
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
