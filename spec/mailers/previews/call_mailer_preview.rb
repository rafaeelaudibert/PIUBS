# Preview all emails at http://localhost:3000/rails/mailers/call_mailer
class CallMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/call_mailer/notification
  def notification
    CallMailerMailer.notification
  end

end
