# frozen_string_literal: true

class ControversyMailer < ApplicationMailer
  def new(controversy_id, user_id)
    @controversy = Controversy.find(controversy_id)
    @current_user = User.find(user_id)
    @link = "#{root_url}/controversias/controversies/#{@controversy.protocol}"

    mail to: @current_user.email,
         subject: "[PIUBS] - Criação de controvérsia #{@controversy.protocol}"
  end
end
