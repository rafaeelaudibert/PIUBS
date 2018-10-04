# frozen_string_literal: true

class ReplyMailer < ApplicationMailer

  def notify(reply, current_user)
    @reply = reply
    @call = Call.find(@reply.protocol)
    @call_user = User.find(@call.user_id)
    @current_user = current_user
    @link = "#{root_url}calls/#{@call.protocol}"

    ReplyWorker.perform_async(reply.id, current_user.id, root_url)
  end

end
