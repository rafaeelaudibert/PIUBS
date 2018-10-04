# frozen_string_literal: true

# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'faker'
require 'logger'
require 'cpf_cnpj'
require 'csv'

# Options for logger.level DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::INFO

# Creates the users, except company_admin and company_user ones
def seed_users
  Rails.logger.info('[START]  -- Users insertion')

  if User.new(cpf: CPF.generate, name: 'Admin Master',
              email: 'admin@piubs.com', role: 'admin', sei: 0,
              password: 'changeme', password_confirmation: 'changeme').save
    User.roles.each do |role|
      # Prevent from creating this, as they will be already created later or have already been created
      next if %w[admin company_admin company_user].include? role[0]

      role_name = role[0]
      email = role_name + '@piubs.com'
      passwd = 'changeme'
      user = User.new(cpf: CPF.generate,
                      name: role_name.capitalize,
                      email: email,
                      password: passwd,
                      password_confirmation: passwd,
                      role: role_name)
      if user.save
        Rails.logger.debug("User #{email} was created successfuly!")
      else
        Rails.logger.error("Error creating user #{email}!")
        Rails.logger.error(user.errors.full_messages)
      end
    end
  else
    Rails.logger.fatal('Error creating ADMIN MASTER USER!')
    raise
  end
  Rails.logger.info('[FINISH] -- Users insertion')
end

def seed_company_user(company, role_name)
  email = "#{role_name}_#{company.sei}@piubs.com"
  user = User.new(sei: company.sei,
                  cpf: CPF.generate,
                  name: role_name,
                  email: email,
                  password: 'changeme',
                  password_confirmation: 'changeme',
                  role: role_name)
  if user.save
    Rails.logger.debug("User #{email} was created successfuly!")
  else
    Rails.logger.error("Error creating user #{email}!")
    Rails.logger.error(user.errors.full_messages)
  end
end

def seed_unity(cnes, name, city)
  ubs = Unity.new(cnes: cnes, name: name, city: city)
  if ubs.save
    Rails.logger.debug("INSERTED a UNITY in #{city.name}: #{name}")
  else
    Rails.logger.error("ERROR inserting UNITY in #{city.name}: #{name}")
    Rails.logger.error(ubs.errors.full_messages)
  end
end

def seed_states
  Rails.logger.info('[START]  -- States insertion')
  CSV.foreach('./public/csv/estados.csv', headers: true) do |row|
    state = State.new(name: row['Und Fed'].titleize,
                      abbr: row['UF'],
                      id: row['COD UF'])
    if state.save
      Rails.logger.debug("INSERTED a STATE in the database: #{state.name}")
    else
      Rails.logger.error("ERROR inserting STATE #{state.name}")
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
      Rails.logger.debug("INSERTED a CITY in the database: #{city.id}")
      seed_contract(city)
    else
      Rails.logger.error("ERROR inserting CITY #{city[:name]}")
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
      Rails.logger.debug("INSERTED a UNITY in the database: #{unity.cnes}")
    else
      Rails.logger.error("ERROR inserting CITY #{unity[:name]}")
      Rails.logger.error(unity.errors.full_messages)
    end
  end
  Rails.logger.info('[FINISH] -- Unities insertion')
end

def seed_contract(city)
  sei = rand(1..20)
  file_content = IO.read(File.join(Rails.root,
                                   'public',
                                   'assets',
                                   'documents',
                                   'contrato.pdf'),
                         mode: 'rb')
  contract = Contract.new(sei: sei,
                          city: city,
                          contract_number: "#{sei}#{city.id}",
                          filename: 'contrato.pdf',
                          content_type: 'application/pdf',
                          file_contents: file_content)
  if contract.save
    Rails.logger.debug("INSERTED a CONTRACT in the database: #{sei}#{city.id}")
  else
    Rails.logger.error("ERROR inserting CONTRACT: #{sei}#{city.id}")
    Rails.logger.error(contract.errors.full_messages)
  end
end

def seed_companies
  Rails.logger.info('[START]  -- Companies insertion')
  if Company.new(sei: 0).save
    (1..20).each do |sei|
      company = Company.new(sei: sei)
      if company.save
        Rails.logger.debug("INSERTED a COMPANY in the database: #{sei}")
        seed_company_user company, 'company_admin'
        seed_company_user company, 'company_user'
      else
        Rails.logger.error("ERROR inserting COMPANY #{sei}")
        Rails.logger.error(company.errors.full_messages)
      end
    end
  else
    Rails.logger.fatal('ERROR inserting MAIN COMPANY')
    raise
  end
  Rails.logger.info('[FINISH] -- Companies insertion')
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

def seed_answers
  size = 2_000
  categories = Category.all
  allowed_users = User.where(role: %w[call_center_admin call_center_user])
  Rails.logger.info('[START]  -- Answers (and FAQ) insertion')
  (1..size).each do |_|
    answer = Answer.new(question: Faker::Lorem.sentence(50, true, 6),
                        answer: Faker::Lorem.sentence(50, true, 6),
                        category_id: categories.sample.id,
                        user: allowed_users.sample,
                        faq: Random.rand > 0.90,
                        keywords: Faker::Lorem.sentence(1, true, 3))
    if answer.save
      Rails.logger.debug('Inserted a new answer')
    else
      Rails.logger.error('ERROR creating an ANSWER')
      Rails.logger.error(answer.errors.full_messages)
    end
  end
  Rails.logger.info('[FINISH] -- Answers (and FAQ) insertion')
end

def seed_calls
  size = 300
  unities = Unity.all
  categories = Category.all
  acess_profiles = %w[Médico Enfermeiro Administrador Secretário]
  Rails.logger.info('[START]  -- Calls insertion')
  (1..size).each do |_|
    ubs = unities.sample
    city = City.find(ubs.city_id)
    contract = Contract.where(city_id: city.id).first
    user = User.where(sei: contract.sei).sample
    protocol = Time.now.strftime('%Y%m%d%H%M%S%L').to_i
    call = Call.new(title: Faker::Lorem.sentence(15, true, 2),
                    description: Faker::Lorem.sentence(80, true, 6),
                    version: ['1.0.0', '1.0.1', '2.0.0', '3.0.0-beta'].sample,
                    access_profile: acess_profiles.sample,
                    feature_detail: %w[Impressão Login Consulta FAQ].sample,
                    severity: Call.severities.keys.sample,
                    status: Call.statuses.keys.sample,
                    protocol: protocol,
                    city_id: city.id,
                    category_id: categories.sample.id,
                    state_id: city.state_id,
                    sei: contract.sei,
                    user_id: user.id,
                    id: protocol,
                    cnes: ubs.cnes)
    if call.save
      Rails.logger.debug('Inserted a new call')
    else
      Rails.logger.error('ERROR creating a CALL')
      Rails.logger.error(call.errors.full_messages)
    end
  end
  Rails.logger.info('[FINISH] -- Calls insertion')
end

def seed_replies
  quantity = 2000
  calls = Call.all
  Rails.logger.info('[START]  -- Replies (and FAQ) insertion')
  (1..quantity).each do |_|
    user = Random.rand > 0.7 ? User.where(role: %w[call_center_admin call_center_user]).sample : User.where(role: %w[company_admin company_user]).sample
    call = calls.sample
    reply = Reply.new(protocol: call.protocol,
                      description: Faker::Lorem.sentence(25, true, 0),
                      user_id: user.id,
                      status: [0, 1, 2].sample,
                      category: %w[company_admin company_user].include?(user.role) ? 'reply' : 'support',
                      faq: %w[company_admin company_user].include?(user.role) ? false : Random.rand > 0.90)
    if reply.save
      Rails.logger.debug("Inserted a new reply to the protocol #{reply.protocol}")
      seed_faq_from_replies(call, reply) if reply.faq
    else
      Rails.logger.error('ERROR creating a REPLY')
      Rails.logger.error(reply.errors.full_messages)
    end
  end
  Rails.logger.info('[FINISH] -- Replies (and FAQ) insertion')
end

def seed_faq_from_replies(call, reply)
  answer = Answer.new(question: call.title,
                      answer: reply.description,
                      category_id: call.category_id,
                      user: reply.user,
                      faq: true,
                      keywords: Faker::Lorem.sentence(1, true, 3))
  if answer.save
    Rails.logger.debug('Inserted a new FAQ answer')
  else
    Rails.logger.error('ERROR creating a FAQ ANSWER')
    Rails.logger.error(answer.errors.full_messages)
  end
end

def main
  Rails.logger.warn('[START]  SEED')
  seed_companies
  seed_users
  seed_states
  seed_cities
  seed_unities
  seed_categories
  seed_answers
  seed_calls
  seed_replies
  Rails.logger.warn('[FINISH] SEED')
end

main
