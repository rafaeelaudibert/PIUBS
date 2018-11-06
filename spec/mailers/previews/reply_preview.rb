# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/reply
class ReplyPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/reply/reply_mailer
  def reply_mailer
    CallReplyMailer.reply_mailer
  end

  # Preview this email at http://localhost:3000/rails/mailers/reply/notification
  def notification
    CallReplyMailer.notification
  end
end
