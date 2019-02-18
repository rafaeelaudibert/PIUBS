# frozen_string_literal: true

##
# This is the default mailer for the Devise gem
class DeviseMailer < Devise::Mailer
  # Email which is sent when a user creates his account,
  # containing his account confirmation instructions
  #
  # <b>OBS.:<b> This sign up process is not used in our
  # application, so this method is never called
  def confirmation_instructions(record, token, opts = {})
    mail = super
    mail.subject = '[PIUBS] - Instruções de Confirmação'
    mail
  end

  # Email which is sent when a user changes his e-mail,
  # containing his new account details
  #
  # <b>OBS.:<b> This email change process is not used in our
  # application, so this method is never called
  def email_changed(record, token, opts = {})
    mail = super
    mail.subject = '[PIUBS] - Alteração de e-mail'
    mail
  end

  # Email which is sent when a user is invited to
  # the PIUBS Portal, containing his account
  # creation instructions
  def invitation_instructions(record, token, opts = {})
    mail = super
    mail.subject = '[PIUBS] - Instruções de Confirmação'
    mail
  end

  # Email which is sent when a user changes his password,
  # containing his new account details
  def password_change(record, token, opts = {})
    mail = super
    mail.subject = '[PIUBS] - Alteração de senha'
    mail
  end

  # Email which is sent when a user asks for a password reset,
  # containing instructions to proceede with the process
  def reset_password_instructions(record, token, opts = {})
    mail = super
    mail.subject = '[PIUBS] - Alteração de senha'
    mail
  end

  # Email which is sent when a user asks to unlock
  # his access to the system, containing instructions to do so
  #
  # <b>OBS.:<b> The lock/unlock account process is not used
  # in our application, so this method is never called
  def unlock_instructions(record, token, opts = {})
    mail = super
    mail.subject = '[PIUBS] - Instruções de Desbloqueio'
    mail
  end
end
