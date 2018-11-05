# frozen_string_literal: true

class AttachmentLink < ApplicationRecord
  enum source: %i[answer call reply controversy feedback]
  belongs_to :attachment
  belongs_to :answer, optional: true
  belongs_to :call, optional: true
  belongs_to :reply, optional: true
  belongs_to :controversy, optional: true
  belongs_to :feedback, optional: true

  validates :source, presence: true
end
