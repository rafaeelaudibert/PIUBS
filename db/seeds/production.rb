# frozen_string_literal: true

# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'logger'
require 'csv'

# Options for logger.level DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::INFO

# Creates the users, except company_admin and company_user ones
def seed_users
  return unless Company.new(sei: 0).save

  admin = User.new(cpf: CPF.generate, name: 'Admin Master',
                   email: 'admin@piubs.com', role: 'admin', sei: 0,
                   password: '19550410', password_confirmation: '19550410')
  if admin.save
    Rails.logger.info('[INFO]   -- Created ADMIN MASTER USER!')
  else
    Rails.logger.fatal('[ERROR]  -- Error creating ADMIN MASTER USER!')
    Rails.logger.error(admin.errors)
    raise
  end
end

def seed_states
  Rails.logger.info('[START]  -- States insertion')
  CSV.foreach('./public/csv/estados.csv', headers: true) do |row|
    state = State.new(name: row['Und Fed'].titleize,
                      abbr: row['UF'],
                      id: row['COD UF'])
    if state.save
      Rails.logger.debug("[DEBUG]  -- INSERTED a STATE in the database: #{state.name}")
    else
      Rails.logger.error("[ERROR]  -- ERROR inserting STATE #{state.name}")
      Rails.logger.error(state.errors.full_messages)
    end
  end
  Rails.logger.info('[FINISH] -- States insertion')
end

def seed_cities
  Rails.logger.info('[START]  -- Cities insertion')
  CSV.foreach('./public/csv/municipios.csv', headers: true) do |row|
    city = City.new(name: row['NOME MUNIC'],
                    state_id: row['COD UF'],
                    id: row['CodMun'][0...-1])
    if city.save
      Rails.logger.debug("[DEBUG]  -- INSERTED a CITY in the database: #{city.id}")
    else
      Rails.logger.error("[ERROR]  -- ERROR inserting CITY #{city[:name]}")
      Rails.logger.error(city.errors.full_messages)
    end
  end
  Rails.logger.info('[FINISH] -- Cities insertion')
end

def seed_unities
  Rails.logger.info('[START]  -- Unities insertion')
  CSV.foreach('./public/csv/ubs.csv', headers: true) do |row|
    name = row['nom_estab'] ? row['nom_estab'].titleize : row['nom_estab']
    address = row['dsc_endereco'] ? row['dsc_endereco'].titleize : row['dsc_endereco']
    neighborhood = row['dsc_bairro'] ? row['dsc_bairro'].titleize : row['dsc_bairro']
    phone = row['dsc_telefone'] == 'Não se aplica' ? '' : row['dsc_telefone']
    unity = Unity.new(cnes: row['cod_cnes'],
                      name: name,
                      city_id: row['cod_munic'],
                      address: address,
                      neighborhood: neighborhood,
                      phone: phone)
    if unity.save
      Rails.logger.debug("[DEBUG]  -- INSERTED a UNITY in the database: #{unity.cnes}")
    else
      Rails.logger.error("[ERROR]  -- ERROR inserting CITY #{unity[:name]}")
      Rails.logger.error(unity.errors.full_messages)
    end
  end
  Rails.logger.info('[FINISH] -- Unities insertion')
end

def seed_categories
  Rails.logger.info('[START]  -- Categories insertion')
  category = Category.new # placeholder

  begin
    category = Category.new(name: 'Orientações básicas sobre a estratégia e-SUS AB',
                            severity: :low).save!
    category = Category.new(name: 'Orientações básicas sobre a utilização do sistema',
                            severity: :low).save!
    category = Category.new(name: 'Instalação do Sistema',
                            severity: :low).save!
    category = Category.new(name: 'Gerenciamento do cadastro do cidadão',
                            severity: :medium).save!

    #########
    c_fichas = Category.new(name: 'Fichas do e-SUS AB',
                            severity: :medium)
    c_fichas.save!
    category = Category.new(name: 'Ficha Domiciliar',
                            severity: :medium,
                            parent: c_fichas,
                            parent_depth: 1 + c_fichas.parent_depth).save!
    category = Category.new(name: 'Ficha de Cadastro Individual',
                            severity: :medium,
                            parent: c_fichas,
                            parent_depth: 1 + c_fichas.parent_depth).save!
    category = Category.new(name: 'Ficha de Atendimento Odontológico Individual',
                            severity: :medium,
                            parent: c_fichas,
                            parent_depth: 1 + c_fichas.parent_depth).save!
    category = Category.new(name: 'Ficha de Atividade Coletiva',
                            severity: :medium,
                            parent: c_fichas,
                            parent_depth: 1 + c_fichas.parent_depth).save!
    category = Category.new(name: 'Ficha de Procedimentos',
                            severity: :medium,
                            parent: c_fichas,
                            parent_depth: 1 + c_fichas.parent_depth).save!

    category = Category.new(name: 'Coleta de Dados Simplificada (CDS)',
                            severity: :high).save!
    category = Category.new(name: 'Relatório',
                            severity: :high).save!
    category = Category.new(name: 'Transmissão dos Dados',
                            severity: :high).save!

    ###############
    catg_pec = Category.new(name: 'PEC',
                            severity: :low)
    catg_pec.save!
    category = Category.new(name: 'Agenda dos Profissionais',
                            severity: :low,
                            parent: catg_pec,
                            parent_depth: 1 + catg_pec.parent_depth).save!
    category = Category.new(name: 'Atendimentos',
                            severity: :low,
                            parent: catg_pec,
                            parent_depth: 1 + catg_pec.parent_depth).save!
  rescue StandardError
    Rails.logger.error('ERROR creating a CATEGORY')
    Rails.logger.error(category.errors.full_messages)
  end
  Rails.logger.info('[FINISH] -- Categories insertion')
end

def main
  Rails.logger.warn('[START]  SEED')
  seed_users
  seed_states
  seed_cities
  seed_unities
  seed_categories
  Rails.logger.warn('[FINISH] SEED')
end

main
