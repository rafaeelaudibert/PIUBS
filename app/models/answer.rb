# frozen_string_literal: true

##
# This class belongs to both system modules.
#
# It has two functionalities in Apoio a Empresas, as
# it records the final answers given to the Call,
# this is, the final explanation given to the problem.
#
# It also represents questions/answers which are in the FAQ,
# in both systems. This FAQ answers have the :ST_FAQ column
# marked with an 'S' ('Y' in portuguese)

class Answer < ApplicationRecord
  default_scope lambda {
    joins(:category).order(Arel.sql('"TB_CATEGORIA"."NO_NOME"'), :DS_QUESTAO, :DS_RESPOSTA)
  }
  belongs_to :category, foreign_key: :CO_CATEGORIA
  belongs_to :user, foreign_key: :CO_USUARIO
  has_many :attachment_links, foreign_key: :CO_QUESTAO
  has_many :attachments, through: :attachment_links
  has_many :call, foreign_key: :CO_RESPOSTA
  validates :DS_QUESTAO, presence: true
  validates :DS_RESPOSTA, presence: true
  validates :CO_CATEGORIA, presence: true
  validates :CO_USUARIO, presence: true
  validates :ST_FAQ, inclusion: { in: %w[S N],
                                  message: 'this choice is not allowed.' }

  alias_attribute :system, :CO_SISTEMA_ORIGEM
  enum system: { from_call: 1, from_controversy: 2 }

  #### DATABASE adaptations ####
  self.primary_key = :CO_SEQ_ID # Setting a different primary_key
  self.table_name = '"TB_QUESTAO"' # Setting a different table_name

  # Configures an alias setter for the CO_SEQ_ID database column
  def id=(value)
    write_attribute(:CO_SEQ_ID, value)
  end

  # Configures an alias getter for the CO_SEQ_ID database column
  def id
    read_attribute(:CO_SEQ_ID)
  end

  # Configures an alias setter for the DS_QUESTAO database column
  def question=(value)
    write_attribute(:DS_QUESTAO, value)
  end

  # Configures an alias getter for the DS_QUESTAO database column
  def question
    read_attribute(:DS_QUESTAO)
  end

  # Configures an alias setter for the DS_RESPOSTA database column
  def answer=(value)
    write_attribute(:DS_RESPOSTA, value)
  end

  # Configures an alias getter for the DS_RESPOSTA database column
  def answer
    read_attribute(:DS_RESPOSTA)
  end

  # Configures an alias setter for the CO_CATEGORIA database column
  def category_id=(value)
    write_attribute(:CO_CATEGORIA, value)
  end

  # Configures an alias getter for the CO_CATEGORIA database column
  def category_id
    read_attribute(:CO_CATEGORIA)
  end

  # Configures an alias setter for the CO_USUARIO database column
  def user_id=(value)
    write_attribute(:CO_USUARIO, value)
  end

  # Configures an alias getter for the CO_USUARIO database column
  def user_id
    read_attribute(:CO_USUARIO)
  end

  # Configures an alias setter for the DT_CRIADO_EM database column
  def created_at=(value)
    write_attribute(:DT_CRIADO_EM, value)
  end

  # Configures an alias getter for the DT_CRIADO_EM database column
  def created_at
    read_attribute(:DT_CRIADO_EM)
  end

  # Configures a getter for a formatted created_at (DT_CRIADO_EM) field
  def formatted_created_at
    created_at.strftime('%d %b %y - %H:%M:%S')
  end

  # Configures an alias setter for the DS_PALAVRA_CHAVE database column
  def keywords=(value)
    write_attribute(:DS_PALAVRA_CHAVE, value)
  end

  # Configures an alias getter for the DS_PALAVRA_CHAVE database column
  def keywords
    read_attribute(:DS_PALAVRA_CHAVE)
  end

  # Configures an alias setter for the ST_FAQ database column
  def faq=(value)
    if %w[S N].include? value
      write_attribute(:ST_FAQ, value)
    elsif [true, false].include? value
      write_attribute(:ST_FAQ, value == true ? 'S' : 'N')
    else
      write_attribute(:ST_FAQ, !value.to_i.zero? ? 'S' : 'N')
    end
  end

  # Configures an alias getter for the ST_FAQ database column
  def faq
    faq = read_attribute(:ST_FAQ)
    faq == 'S' # If the value stored in FAQ is 'S' returns true else false
  end

  # Configures an alias setter for the CO_SISTEMA_ORIGEM database column
  def system_id=(value)
    write_attribute(:CO_SISTEMA_ORIGEM, value.to_i)
  end

  # Configures an alias getter for the CO_SISTEMA_ORIGEM database column
  def system_id
    read_attribute(:CO_SISTEMA_ORIGEM)
  end

  # Returns all Answer instances which are in the FAQ, no matter
  # if it is related to a Controversy or a Call
  def self.on_faq
    where(ST_FAQ: 'S')
  end

  # Returns all Answer instances which are in the FAQ and are
  # related to a Controversy
  def self.faq_from_controversy
    on_faq.where(CO_SISTEMA_ORIGEM: :from_controversy)
  end

  # Returns all Answer instances which are in the FAQ and are
  # related to a Call
  def self.faq_from_call
    on_faq.where(CO_SISTEMA_ORIGEM: :from_call)
  end

  # Return all Answer instances which were created by the User
  # with <tt>id</tt> same as the passed as a parameter
  def self.from_user(id)
    where(CO_USUARIO: id)
  end

  #### PGSEARCH stuff ####
  include PgSearch
  pg_search_scope :search_for,
                  against: {
                    DS_PALAVRA_CHAVE: 'A',
                    DS_QUESTAO: 'B',
                    DS_RESPOSTA: 'C'
                  },
                  ignoring: :accents,
                  using: {
                    tsearch: { any_word: true,
                               prefix: true,
                               dictionary: :portuguese },
                    trigram: { threshold: 0.1 }
                  }

  #### FILTERRIFIC queries ####
  filterrific default_filter_params: { with_category: 'category_any' },
              available_filters: %i[with_category search_query_faq_call
                                    search_query_faq_controversy search_query]

  scope :search_query, ->(query) { query.blank? ? nil : search_for(query) }

  scope :search_query_faq_call, lambda { |query|
    return nil if query.blank?

    unscoped.faq_from_call.search_for query
  }

  scope :search_query_faq_controversy, lambda { |query|
    return nil if query.blank?

    unscoped.faq_from_controversy.search_for(query)
  }

  scope :with_category, lambda { |category_id|
    return nil if category_id == 'category_any'

    where(ST_FAQ: 'S', CO_CATEGORIA: category_id)
  }
end
