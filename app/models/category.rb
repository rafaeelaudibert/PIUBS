# frozen_string_literal: true

##
# This class is a generic database model to represent a Category which is hold by some "categorizable" models.
#
# The "categorized" models are: Answer, Call and Controversy.
class Category < ApplicationRecord
  default_scope -> { order('"CO_SISTEMA_ORIGEM", "NO_NOME"') }
  belongs_to :parent, class_name: 'Category',
                      foreign_key: :CO_CATEGORIA_PAI, optional: true
  has_many :children, ->(category) { where(CO_CATEGORIA_PAI: category.id) },
           class_name: :Category
  has_many :answer
  validates :NO_NOME, presence: true, uniqueness: true

  alias_attribute :severity, :NU_SEVERIDADE
  enum severity: %i[low medium high]

  alias_attribute :source, :CO_SISTEMA_ORIGEM
  enum source: %i[from_call from_controversy]

  #### DATABASE adaptations ####
  self.primary_key = :CO_SEQ_ID # Setting a different primary_key
  self.table_name = :TB_CATEGORIA # Setting a different table_name

  # Configures an alias setter for the CO_SEQ_ID database column
  def id=(value)
    write_attribute(:CO_SEQ_ID, value)
  end

  # Configures an alias getter for the CO_SEQ_ID database column
  def id
    read_attribute(:CO_SEQ_ID)
  end

  # Configures an alias setter for the NO_NOME database column
  def name=(value)
    write_attribute(:NO_NOME, value)
  end

  # Configures an alias getter for the NO_NOME database column
  def name
    read_attribute(:NO_NOME)
  end

  # Configures an alias setter for the CO_CATEGORIA_PAI database column
  def parent_id=(value)
    write_attribute(:CO_CATEGORIA_PAI, value)
  end

  # Configures an alias getter for the CO_CATEGORIA_PAI database column
  def parent_id
    read_attribute(:CO_CATEGORIA_PAI)
  end

  # Configures an alias setter for the NU_PROFUNDIDADE database column
  def parent_depth=(value)
    write_attribute(:NU_PROFUNDIDADE, value)
  end

  # Configures an alias getter for the NU_PROFUNDIDADE database column
  def parent_depth
    read_attribute(:NU_PROFUNDIDADE)
  end

  # Configures an alias setter for the NU_SEVERIDADE database column
  def severity=(value)
    write_attribute(:NU_SEVERIDADE, value)
  end

  # Configures an alias getter for the CO_SISTEMA_ORIGEM database column
  def severity
    read_attribute(:CO_SISTEMA_ORIGEM)
  end

  # Configures an alias setter for the CO_SISTEMA_ORIGEM database column
  def source=(value)
    write_attribute(:CO_SISTEMA_ORIGEM, value)
  end

  # Configures an alias getter for the NU_SEVERIDADE database column
  def source
    read_attribute(:NU_SEVERIDADE)
  end

  #### FILTERRIFIC queries ####
  filterrific available_filters: %i[search_query]

  scope :search_query, lambda { |query|
    return nil if query.blank?

    where('"NO_NOME" ILIKE :search', search: "%#{query}%")
  }
end
