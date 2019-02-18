# frozen_string_literal: true

# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'logger'
require 'csv'
require 'cpf_cnpj'

# Options for logger.level DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::INFO

def seed_users
  return unless Company.new(sei: 0, name: 'Suporte - CallCenter', cnpj: CNPJ.generate(true)).save

  admin = User.new(cpf: CPF.generate(true), name: 'Admin Master',
                   email: 'admin@piubs.com', role: 'admin', sei: 0,
                   password: '19550410', password_confirmation: '19550410',
                   system: :both)
  if admin.save
    Rails.logger.info('[INFO]   -- Created ADMIN MASTER USER!')
  else
    Rails.logger.fatal('[ERROR]  -- Error creating ADMIN MASTER USER!')
    Rails.logger.error(admin.errors)
    raise 'Error creating ADMIN MASTER USER!'
  end
end

def seed_states
  Rails.logger.info('[START]  -- States insertion')
  CSV.foreach('./app/assets/static/estados.csv', headers: true) do |row|
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
  CSV.foreach('./app/assets/static/municipios.csv', headers: true) do |row|
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
  CSV.foreach('./app/assets/static/ubs.csv', headers: true) do |row|
    unity = Unity.new(cnes: row['cod_cnes'],
                      name: row['nom_estab']&.titleize,
                      city_id: row['cod_munic'],
                      address: row['dsc_endereco']&.titleize,
                      neighborhood: row['dsc_bairro']&.titleize,
                      phone: row['dsc_telefone'] == 'Não se aplica' ? '' : row['dsc_telefone'])
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
    ####
    # APOIO A EMPRESAS CATEGORIES
    ##

    category = Category.new(name: 'Orientações básicas sobre a estratégia e-SUS AB',
                            severity: :low, system: :from_call).save!
    category = Category.new(name: 'Orientações básicas sobre a utilização do sistema',
                            severity: :low, system: :from_call).save!
    category = Category.new(name: 'Instalação do Sistema',
                            severity: :low, system: :from_call).save!
    category = Category.new(name: 'Gerenciamento do cadastro do cidadão',
                            severity: :medium, system: :from_call).save!

    ### Sub-categorias para 'Fichas do e-SUS AB'
    c_fichas = Category.new(name: 'Fichas do e-SUS AB',
                            severity: :medium, system: :from_call)
    c_fichas.save!

    category = Category.new(name: 'Ficha Domiciliar',
                            severity: :medium,
                            parent: c_fichas,
                            parent_depth: 1 + c_fichas.parent_depth,
                            system: :from_call).save!
    category = Category.new(name: 'Ficha de Cadastro Individual',
                            severity: :medium,
                            parent: c_fichas,
                            parent_depth: 1 + c_fichas.parent_depth,
                            system: :from_call).save!
    category = Category.new(name: 'Ficha de Atendimento Odontológico Individual',
                            severity: :medium,
                            parent: c_fichas,
                            parent_depth: 1 + c_fichas.parent_depth,
                            system: :from_call).save!
    category = Category.new(name: 'Ficha de Atividade Coletiva',
                            severity: :medium,
                            parent: c_fichas,
                            parent_depth: 1 + c_fichas.parent_depth,
                            system: :from_call).save!
    category = Category.new(name: 'Ficha de Procedimentos',
                            severity: :medium,
                            parent: c_fichas,
                            parent_depth: 1 + c_fichas.parent_depth,
                            system: :from_call).save!

    category = Category.new(name: 'Coleta de Dados Simplificada (CDS)',
                            severity: :high, system: :from_call).save!
    category = Category.new(name: 'Relatório',
                            severity: :high, system: :from_call).save!
    category = Category.new(name: 'Transmissão dos Dados',
                            severity: :high, system: :from_call).save!

    ### Sub-categorias para 'PEC'
    catg_pec = Category.new(name: 'PEC',
                            severity: :low, system: :from_call)
    catg_pec.save!
    category = Category.new(name: 'Agenda dos Profissionais',
                            severity: :low,
                            parent: catg_pec,
                            parent_depth: 1 + catg_pec.parent_depth,
                            system: :from_call).save!
    category = Category.new(name: 'Atendimentos',
                            severity: :low,
                            parent: catg_pec,
                            parent_depth: 1 + catg_pec.parent_depth,
                            system: :from_call).save!

    ####
    # SOLUCAO DE CONTROVERSIAS CATEGORIES
    ##

    category = Category.new(name: 'Hardware',
                            severity: :low, system: :from_controversy).save!
    category = Category.new(name: 'Software',
                            severity: :low, system: :from_controversy).save!
  rescue StandardError
    Rails.logger.error("[ERROR]  -- ERROR creating a CATEGORY - #{category.name}")
    Rails.logger.error(category.errors.full_messages)
  end
  Rails.logger.info('[FINISH] -- Categories insertion')
end

def seed_faq
  Rails.logger.info('[START]  -- FAQ insertion')

  JSON.parse(File.read('./app/assets/static/faq.json')).each do |json_data|
    answer = Answer.new(json_data)

    if answer.save
      Rails.logger.debug('[DEBUG]  -- INSERTED an ANSWER to the FAQ in the database')
    else
      Rails.logger.error('[ERROR]  -- ERROR inserting an ANSWER to the FAQ')
      Rails.logger.error(answer.errors.full_messages)
    end
  end

  Rails.logger.info('[FINISH] -- FAQ insertion')
end

def main
  Rails.logger.warn('[START]  SEED')
  seed_users
  seed_states
  seed_cities
  seed_unities
  seed_categories
  seed_faq
  Rails.logger.warn('[FINISH] SEED')
end

main
