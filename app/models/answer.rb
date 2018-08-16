class Answer < ApplicationRecord
  belongs_to :category
  belongs_to :user
  has_many :attachment

  # PgSearch stuff
  include PgSearch
  pg_search_scope :search_for, against: {
    question: 'A',
    answer: 'B'
  }, using: { tsearch: { any_word: true,
                         prefix: true } }
end
