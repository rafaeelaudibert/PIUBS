# frozen_string_literal: true

##
# This is the mailer for the Controversy model
class ControversyMailer < ApplicationMailer
  # Sends an e-mail to the User instance
  # which is passed as a parameter notifying about
  # the creation of the Controversy
  def new_controversy(controversy_id, user_id)
    @controversy = Controversy.find(controversy_id)
    @current_user = User.find(user_id)
    @link = "#{root_url}/controversias/controversies/#{@controversy.protocol}"

    mail to: @current_user.email,
         subject: "[PIUBS] - Criação de controvérsia #{@controversy.protocol}"
  end

  # Sends an e-mail to the User instance
  # which is passed as a parameter notifying that
  # he was added in a Controversy by the <tt>support_user</tt>
  def user_added(controversy_id, user_id)
    @controversy = Controversy.find(controversy_id)
    @current_user = User.find(user_id)
    @link = "#{root_url}/controversias/controversies/#{@controversy.protocol}"
    @user_creator = begin
                      User.find(@controversy[@controversy.creator + '_user_id']).name
                    rescue StandardError
                      'Sem usuário criador (Relate ao suporte)'
                    end

    mail to: @current_user.email,
         subject: "[PIUBS] - Envolvimento na controvérsia #{@controversy.protocol}"
  end
end
