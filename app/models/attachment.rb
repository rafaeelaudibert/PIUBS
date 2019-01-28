# frozen_string_literal: true

##
# This class represents an Attachment which can be stored in the
# database by the following models: Call, Reply, Answer,
# Controversy or Feedback
#
# The AttachmentLink relation table is the responsible for
# identifying the enumerous relations of this model.
# We shall have a relation table because the same attachment,
# can have relations with tons of differents other entities.
#--
# FIXME: Use NFS to store the contracts instead of a BLOB field
#++
class Attachment < ApplicationRecord
  has_many :attachment_links, foreign_key: :CO_ANEXO
  has_many :calls, through: :attachment_links
  has_many :replies, through: :attachment_links
  has_many :answers, through: :attachment_links
  has_many :controversies, through: :attachment_links
  has_many :feedbacks, through: :attachment_links
  validates :NO_NOME_ANEXO, presence: true
  validates :DS_TIPO_ANEXO, presence: true
  validates :BL_CONTEUDO, presence: true

  #### DATABASE adaptations ####

  self.primary_key = :CO_ID # Setting a different primary_key
  self.table_name = :TB_ANEXO # Setting a different table_name

  # Configures an alias setter for the CO_ID database column
  def id=(value)
    write_attribute(:CO_ID, value)
  end

  # Configures an alias getter for the CO_ID database column
  def id
    read_attribute(:CO_ID)
  end

  # Configures an alias setter for the NO_NOME_ANEXO database column
  def filename=(value)
    write_attribute(:NO_NOME_ANEXO, value)
  end

  # Configures an alias getter for the NO_NOME_ANEXO database column
  def filename
    read_attribute(:NO_NOME_ANEXO)
  end

  # Configures an alias setter for the DS_TIPO_ANEXO database column
  def content_type=(value)
    write_attribute(:DS_TIPO_ANEXO, value)
  end

  # Configures an alias getter for the DS_TIPO_ANEXO database column
  def content_type
    read_attribute(:DS_TIPO_ANEXO)
  end

  # Configures an alias setter for the BL_CONTEUDO database column
  def file_contents=(value)
    write_attribute(:BL_CONTEUDO, value)
  end

  # Configures an alias getter for the BL_CONTEUDO database column
  def file_contents
    read_attribute(:BL_CONTEUDO)
  end

  # Configures an alias setter for the DT_CRIADO_EM database column
  def created_at=(value)
    write_attribute(:DT_CRIADO_EM, value)
  end

  # Configures an alias getter for the DT_CRIADO_EM database column
  def created_at
    read_attribute(:DT_CRIADO_EM)
  end
end
