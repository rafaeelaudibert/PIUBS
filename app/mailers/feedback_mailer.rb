# frozen_string_literal: true

class FeedbackMailer < ApplicationMailer
  def notify(feedback_id, user_id)
    @feedback = Feedback.find(feedback_id)
    @controversy = @feedback.controversy
    @user = User.find(user_id)
    @link = "#{root_url}controversies/#{@controversy.protocol}"

    mail to: @user.email,
         subject: "[PIUBS] - Parecer final para controvérsia #{@controversy.protocol}"
  end
end
