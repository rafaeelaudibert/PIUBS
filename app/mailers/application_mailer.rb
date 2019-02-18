# frozen_string_literal: true

##
# This is the general mailer for the Application, where we make
# the basic configuration to all the email which will be sent
# by this system
#
# All the other mailers inherit from this one
class ApplicationMailer < ActionMailer::Base
  default from: 'PIUBS <apoio.piubs@gmail.com>'
  layout 'mailer'
end
