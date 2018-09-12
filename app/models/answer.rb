class Answer < ApplicationRecord
  belongs_to :category
  belongs_to :user
  has_many :attachment_links
  has_many :attachments, through: :attachment_links
  has_many :call
  validates :question, presence: true
  validates :keywords, presence: true
  validates :answer, presence: true
  validates :category_id, presence: true
  validates :user_id, presence: true
  validates :faq, inclusion: { in: [true, false],
                               message: 'this one is not allowed. Choose from True or False' }

  # PgSearch stuff
  include PgSearch
  pg_search_scope :search_for,
                  against: {
                    keywords: 'A',
                    question: 'B',
                    answer: 'C'
                  },
                  ignoring: :accents,
                  using: {
                    tsearch: { any_word: true,
                               prefix: true,
                               dictionary: :portuguese },
                    trigram: { threshold: 0.1 }
                  }
end
