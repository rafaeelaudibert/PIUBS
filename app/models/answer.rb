# frozen_string_literal: true

class Answer < ApplicationRecord
  belongs_to :category, foreign_key: :CO_CATEGORIA
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

  enum source: %i[from_call from_controversy]

  # Configures an alias setter for the CO_CATEGORIA database column
  def category_id=(value)
    write_attribute(:CO_CATEGORIA, value)
  end

  # Configures an alias getter for the CO_CATEGORIA database column
  def category_id
    read_attribute(:CO_CATEGORIA)
  end

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

  filterrific(
    default_filter_params: { with_category: 'category_any' },
    available_filters: %i[with_category search_query_faq_call
                          search_query_faq_controversy search_query]
  )

  scope :search_query, lambda { |query|
    return nil if query.blank?

    search_for query
  }

  scope :search_query_faq_call, lambda { |query|
    return nil if query.blank?

    where(faq: true, source: :from_call).search_for query
  }

  scope :search_query_faq_controversy, lambda { |query|
    return nil if query.blank?

    where(faq: true, source: :from_controversy).search_for query
  }

  scope :with_category, lambda { |category_id|
    return nil if category_id == 'category_any'

    where(faq: true, category_id: category_id) if category_id != 'category_id'
  }
end
