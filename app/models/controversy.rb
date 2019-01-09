# frozen_string_literal: true

##
# Principal class in the Solucao de Controversias module.
#
# It is the responsible for managing a problem between a
# Company and a City (and possibly a Unity).
#
# When a Controversy is closed, a Feedback will be generated,
# containing relevant informations about the former.

class Controversy < ApplicationRecord
  before_create :generate_protocol

  belongs_to :company, foreign_key: :CO_SEI
  belongs_to :category, foreign_key: :CO_CATEGORIA
  belongs_to :city, foreign_key: :CO_CIDADE
  belongs_to :unity, foreign_key: :CO_CNES, optional: true
  belongs_to :company_user, class_name: 'User', optional: true, foreign_key: :CO_USUARIO_EMPRESA
  belongs_to :unity_user, class_name: 'User', optional: true, foreign_key: :CO_USUARIO_UNIDADE
  belongs_to :city_user, class_name: 'User', optional: true, foreign_key: :CO_USUARIO_CIDADE
  belongs_to :support_1, foreign_key: :CO_SUPORTE, class_name: 'User', optional: true
  belongs_to :support_2, foreign_key: :CO_SUPORTE_ADICIONAL, class_name: 'User', optional: true
  has_many :attachment_links, foreign_key: :CO_CONTROVERSIA
  has_many :attachments, through: :attachment_links
  has_many :replies, as: :repliable, foreign_key: :CO_PROTOCOLO
  has_one :feedback, foreign_key: :CO_CONTROVERSIA

  alias_attribute :creator, :CO_CRIADO_POR
  enum creator: %i[company unity city support]

  alias_attribute :status, :TP_STATUS
  enum status: %i[open closed on_hold on_ministry]

  #### DATABASE adaptations ####
  self.primary_key = :CO_PROTOCOLO # Setting a different primary_key
  self.table_name = :TB_CONTROVERSIA # Setting a different table_name

  # Configures an alias setter for the CO_PROTOCOLO database column
  def protocol=(value)
    write_attribute(:CO_PROTOCOLO, value)
  end

  # Configures an alias getter for the CO_PROTOCOLO database column
  def protocol
    read_attribute(:CO_PROTOCOLO)
  end

  # Configures an alias setter for the DS_TITULO database column
  def title=(value)
    write_attribute(:DS_TITULO, value)
  end

  # Configures an alias getter for the DS_TITULO database column
  def title
    read_attribute(:DS_TITULO)
  end

  # Configures an alias setter for the DS_DESCRICAO database column
  def description=(value)
    write_attribute(:DS_DESCRICAO, value)
  end

  # Configures an alias getter for the DS_DESCRICAO database column
  def description
    read_attribute(:DS_DESCRICAO)
  end

  # Configures an alias setter for the DT_FINALIZADO_EM database column
  def closed_at=(value)
    write_attribute(:DT_FINALIZADO_EM, value)
  end

  # Configures an alias getter for the DT_FINALIZADO_EM database column
  def closed_at
    read_attribute(:DT_FINALIZADO_EM)
  end

  # Configures an alias setter for the TP_STATUS database column
  def status=(value)
    write_attribute(:TP_STATUS, value)
  end

  # Configures an alias getter for the TP_STATUS database column
  def status
    read_attribute(:TP_STATUS)
  end

  # Configures an alias setter for the CO_SEI database column
  def sei=(value)
    write_attribute(:CO_SEI, value)
  end

  # Configures an alias getter for the CO_SEI database column
  def sei
    read_attribute(:CO_SEI)
  end

  # Configures an alias setter for the CO_CIDADE database column
  def city_id=(value)
    write_attribute(:CO_CIDADE, value)
  end

  # Configures an alias getter for the CO_CIDADE database column
  def city_id
    read_attribute(:CO_CIDADE)
  end

  # Configures an alias setter for the CO_CNES database column
  def cnes=(value)
    write_attribute(:CO_CNES, value)
  end

  # Configures an alias getter for the CO_CNES database column
  def cnes
    read_attribute(:CO_CNES)
  end

  # Configures an alias setter for the CO_USUARIO_EMPRESA database column
  def company_user_id=(value)
    write_attribute(:CO_USUARIO_EMPRESA, value)
  end

  # Configures an alias getter for the CO_USUARIO_EMPRESA database column
  def company_user_id
    read_attribute(:CO_USUARIO_EMPRESA)
  end

  # Configures an alias setter for the CO_USUARIO_UNIDADE database column
  def unity_user_id=(value)
    write_attribute(:CO_USUARIO_UNIDADE, value)
  end

  # Configures an alias getter for the CO_USUARIO_UNIDADE database column
  def unity_user_id
    read_attribute(:CO_USUARIO_UNIDADE)
  end

  # Configures an alias setter for the CO_USUARIO_CIDADE database column
  def city_user_id=(value)
    write_attribute(:CO_USUARIO_CIDADE, value)
  end

  # Configures an alias getter for the CO_USUARIO_CIDADE database column
  def city_user_id
    read_attribute(:CO_USUARIO_CIDADE)
  end

  # Configures an alias setter for the CO_CRIADO_POR database column
  def creator=(value)
    write_attribute(:CO_CRIADO_POR, value)
  end

  # Configures an alias getter for the CO_CRIADO_POR database column
  def creator
    read_attribute(:CO_CRIADO_POR)
  end

  # Configures an alias setter for the CO_CATEGORIA database column
  def category_id=(value)
    write_attribute(:CO_CATEGORIA, value)
  end

  # Configures an alias getter for the CO_CATEGORIA database column
  def category_id
    read_attribute(:CO_CATEGORIA)
  end

  # Configures an alias setter for the NU_COMPLEXIDADE database column
  def complexity=(value)
    write_attribute(:NU_COMPLEXIDADE, value)
  end

  # Configures an alias getter for the NU_COMPLEXIDADE database column
  def complexity
    read_attribute(:NU_COMPLEXIDADE)
  end

  # Configures an alias setter for the DT_CRIADO_EM database column
  def created_at=(value)
    write_attribute(:DT_CRIADO_EM, value)
  end

  # Configures an alias getter for the DT_CRIADO_EM database column
  def created_at
    read_attribute(:DT_CRIADO_EM)
  end

  # Configures an alias setter for the CO_SUPORTE database column
  def support_1_user_id=(value)
    write_attribute(:CO_SUPORTE, value)
  end

  # Configures an alias getter for the CO_SUPORTE database column
  def support_1_user_id
    read_attribute(:CO_SUPORTE)
  end

  # Configures an alias setter for the CO_SUPORTE_ADICIONAL database column
  def support_2_user_id=(value)
    write_attribute(:CO_SUPORTE_ADICIONAL, value)
  end

  # Configures an alias getter for the CO_SUPORTE_ADICIONAL database column
  def support_2_user_id
    read_attribute(:CO_SUPORTE_ADICIONAL)
  end

  # Retrive all replies linked to Controversy, sorted by creation date
  def replies_sorted
    replies.order(DT_CRIADO_EM: :DESC)
  end

  #### FILTERRIFIC queries ####
  filterrific available_filters: %i[search_query]

  scope :search_query, lambda { |query|
    return nil if query.blank?

    where('"DS_TITULO" ILIKE :search OR "DS_DESCRICAO" ILIKE :search', search: "%#{query}%")
  }

  # Method which returns all the User instances who which participating in the Controversy
  def all_users
    [company_user,
     unity_user,
     city_user,
     support_1,
     support_2].reject(&:nil?)
  end

  # Method which returns all the User instances which are participating in the Controversy,
  # excluding the support ones
  def involved_users
    [company_user, unity_user, city_user].reject(&:nil?)
  end

  protected

  # Generate the Controversy protocol
  def generate_protocol
    self.protocol = 0.seconds.from_now.strftime('%Y%m%d%H%M%S%L').to_i
  end
end
