# frozen_string_literal: true

class AttachmentLink < ApplicationRecord
  enum source: %i[answer call reply controversy]
  belongs_to :attachment
  belongs_to :answer, optional: true
  belongs_to :call, optional: true
  belongs_to :reply, optional: true
  belongs_to :controversy, optional: true

  validates :source, presence: true
end
