# frozen_string_literal: true

class DeviseMailer < Devise::Mailer
  def confirmation_instructions(record, token, opts = {})
    mail = super
    mail.subject = '[PIUBS] - Instruções de Confirmação'
    mail
  end

  def email_changed(record, token, opts = {})
    mail = super
    mail.subject = '[PIUBS] - Alteração de e-mail'
    mail
  end

  def invitation_instructions(record, token, opts = {})
    mail = super
    mail.subject = '[PIUBS] - Instruções de Confirmação'
    mail
  end

  def password_change(record, token, opts = {})
    mail = super
    mail.subject = '[PIUBS] - Alteração de senha'
    mail
  end

  def reset_password_instructions(record, token, opts = {})
    mail = super
    mail.subject = '[PIUBS] - Alteração de senha'
    mail
  end

  def unlock_instructions(record, token, opts = {})
    mail = super
    mail.subject = '[PIUBS] - Instruções de Desbloqueio'
    mail
  end
end
