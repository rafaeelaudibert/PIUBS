# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'PIUBS - Apoio a Empresas <apoio.piubs@gmail.com>'
  layout 'mailer'
end
