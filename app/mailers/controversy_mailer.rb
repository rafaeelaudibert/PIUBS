# frozen_string_literal: true

class ControversyMailer < ApplicationMailer
  def new_controversy(controversy_id, user_id)
    @controversy = Controversy.find(controversy_id)
    @current_user = User.find(user_id)
    @link = "#{root_url}/controversias/controversies/#{@controversy.protocol}"

    mail to: @current_user.email,
         subject: "[PIUBS] - Criação de controvérsia #{@controversy.protocol}"
  end

  def user_added(controversy_id, user_id)
    @controversy = Controversy.find(controversy_id)
    @current_user = User.find(user_id)
    @link = "#{root_url}/controversias/controversies/#{@controversy.protocol}"
    @user_reator = begin
                      User.find(@controversy[@controversy.creator + '_user_id']).name
                    rescue StandardError
                      'Sem usuário criador (Relate ao suporte)'
                    end

    mail to: @current_user.email,
         subject: "[PIUBS] - Envolvimento na controvérsia #{@controversy.protocol}"
  end
end
