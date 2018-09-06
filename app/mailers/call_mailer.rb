class CallMailer < ApplicationMailer
  def notify(call, current_user)
    @call = call
    @current_user = current_user
    @link = "#{root_url}calls/#{@call.protocol}"

    mail to: @current_user.email
  end
end
