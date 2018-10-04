# frozen_string_literal: true

class Answer < ApplicationRecord
  belongs_to :category
  belongs_to :user
  has_many :attachment_links
  has_many :attachments, through: :attachment_links
  has_many :call
  validates :question, presence: true
  validates :answer, presence: true
  validates :category_id, presence: true
  validates :user_id, presence: true
  validates :faq, inclusion: { in: [true, false],
                               message: 'this one is not allowed.
                                          Choose from True or False' }

  filterrific(
    default_filter_params: { with_category: 'category_any' },
    available_filters: [
      :with_category
    ]
  )

  scope :with_category, lambda { |category_id|
    return nil if category_id == 'category_any'
    where(faq: true, category_id: category_id) if category_id != 'category_id'
  }

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
