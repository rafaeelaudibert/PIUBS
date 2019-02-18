# frozen_string_literal: true

##
# This is the mailer for the Controversy model
class FeedbackMailer < ApplicationMailer
  # Sends an e-mail to the User instance
  # which is passed as a parameter notifying about
  # the end of a controversy, and the consequently
  # creation of a Feedback with the result of the process
  def notify(feedback_id, user_id)
    @feedback = Feedback.find(feedback_id)
    @controversy = @feedback.controversy
    @user = User.find(user_id)
    @link = "#{root_url}controversies/#{@controversy.protocol}"

    mail to: @user.email,
         subject: "[PIUBS] - Parecer final para controvérsia #{@controversy.protocol}"
  end
end
