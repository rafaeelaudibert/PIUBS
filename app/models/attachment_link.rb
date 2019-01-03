# frozen_string_literal: true

class AttachmentLink < ApplicationRecord
  enum source: %i[answer call reply controversy feedback]
  belongs_to :attachment, foreign_key: :CO_ID
  belongs_to :answer, optional: true
  belongs_to :call, optional: true
  belongs_to :reply, optional: true
  belongs_to :controversy, optional: true
  belongs_to :feedback, optional: true

  validates :source, presence: true

  # Configures an alias setter for the CO_ID database column
  def contract_id=(value)
    write_attribute(:CO_ID, value)
  end

  # Configures an alias getter for the CO_ID database column
  def contract_id
    read_attribute(:CO_ID)
  end
end
