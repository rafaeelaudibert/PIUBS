class Answer < ApplicationRecord
  belongs_to :category
  belongs_to :user
  has_many :attachment
  has_many :call

  # PgSearch stuff
  include PgSearch
  pg_search_scope :search_for, against: {
    question: 'A',
    answer: 'B'
  }, using: { tsearch: { any_word: true, negation: true } }
end
