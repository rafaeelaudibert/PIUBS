# frozen_string_literal: true

class DeviseWorker
  include Sidekiq::Worker

  def perform(devise_mailer, method, user_id, *args)
    user = User.find(user_id)
    devise_mailer.safe_constantize.send(method, user, *args).deliver_now
    logger.info "Performing #{method} with user #{User.find(user_id)}"
  end
end
