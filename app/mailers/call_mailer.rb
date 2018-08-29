class CallMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.call_mailer.notification.subject
  #
  def notification(call, current_user)
    @call = call
    @current_user = current_user
    @link = "#{root_url}calls/#{@call.protocol}"

    mail to: @current_user.email
  end
end
