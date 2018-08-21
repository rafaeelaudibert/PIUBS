class Attachment < ApplicationRecord
  belongs_to :answer
  validate :size_validation

  private

  # TODO: Test if this really works, trying to bypass the frontend security
  def size_validation
    errors[:file] << 'Should be less than 2MB' if file.size > 2.megabytes
  end
end
