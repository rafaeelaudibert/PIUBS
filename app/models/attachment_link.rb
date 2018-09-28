# frozen_string_literal: true

class AttachmentLink < ApplicationRecord
  enum source: %i[answer call reply]
  belongs_to :attachment
  belongs_to :answer, optional: true
  belongs_to :call, optional: true
  belongs_to :reply, optional: true

  validates :source, presence: true
end
