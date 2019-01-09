# frozen_string_literal: true

##
# Worker for the Devise Gem, to perform async mail sending
class DeviseWorker
  include Sidekiq::Worker

  # Configures Devise to send e-mails in the background,
  # so that the browser from the user is not blocked,
  # waiting for a page, while Devise is still sending an e-mail
  def perform(devise_mailer, method, user_id, *args)
    user = User.find(user_id)
    devise_mailer.safe_constantize.send(method, user, *args).deliver_now
    logger.info "[DeviseWorker] Performing #{method} with user #{User.find(user_id)}"
  end
end
