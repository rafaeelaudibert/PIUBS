# frozen_string_literal: true

class Feedback < ApplicationRecord
  has_many :attachment_links, foreign_key: :CO_FEEDBACK
  has_many :attachments, through: :attachment_links
  belongs_to :controversy
end
