# frozen_string_literal: true

require 'faker'
require 'logger'
require 'cpf_cnpj'
require 'csv'

# Options for logger.level DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::INFO

# Create the 2 basyc sistems in the database
def seed_systems
  System.new(name: 'APOIO_A_EMPRESAS').save!
  System.new(name: 'SOLUCAO_DE_CONTROVERSIAS').save!
end

def seed_event_types
  EventType.new(name: 'ALTERATION').save!
  EventType.new(name: 'REPLY').save!
end

# Creates the users, except company_admin and company_user ones
def seed_users
  Rails.logger.info('[START]  -- Users insertion')

  if User.new(cpf: CPF.generate, name: 'Admin Master',
              email: 'admin@piubs.com', role: 'admin', sei: 0,
              password: 'changeme', password_confirmation: 'changeme',
              system: :both).save
    User.roles.each do |role|
      # Prevent from creating this, as they will be/have already been handled
      next if %w[admin company_admin company_user].include? role[0]

      email = role[0] + '@piubs.com'
      user = User.new(cpf: CPF.generate, name: role[0].capitalize,
                      email: email, role: role[0],
                      password: 'changeme', password_confirmation: 'changeme',
                      system: if %w[call_center_admin call_center_user].include? role[0]
                                :both
                              else
                                :companies
                              end)
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
                  role: role_name,
                  system: :both)
  if user.save
    Rails.logger.debug("User #{email} was created successfuly!")
  else
    Rails.logger.error("Error creating user #{email}!")
    Rails.logger.error(user.errors.full_messages)
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

  counter = 0
  CSV.foreach('./public/csv/municipios.csv', headers: true) do |row|
    if (counter % 15).zero?
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

    counter += 1
  end
  Rails.logger.info('[FINISH] -- Cities insertion')
end

def seed_unities
  Rails.logger.info('[START]  -- Unities insertion')

  city_ids = City.all.ids.to_a

  CSV.foreach('./public/csv/ubs.csv', headers: true) do |row|
    if city_ids.include?(row['cod_munic'].to_i)
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
        Rails.logger.error("ERROR inserting UNITY #{unity[:name]}")
        Rails.logger.error(unity.errors.full_messages)
      end
    end
  end
  Rails.logger.info('[FINISH] -- Unities insertion')
end

def seed_contract(city)
  company = Company.all.sample
  file_content = IO.read(File.join(Rails.root,
                                   'public',
                                   'assets',
                                   'documents',
                                   'contrato.pdf'),
                         mode: 'rb')
  contract = Contract.new(company: company,
                          city: city,
                          contract_number: "#{company.sei}#{city.id}",
                          filename: 'contrato.pdf',
                          content_type: 'application/pdf',
                          file_contents: file_content)
  if contract.save
    Rails.logger.debug("INSERTED a CONTRACT in the database: #{company.sei}#{city.id}")
  else
    Rails.logger.error("ERROR inserting CONTRACT: #{sei}#{city.id}")
    Rails.logger.error(contract.errors.full_messages)
  end
end

def seed_companies
  Rails.logger.info('[START]  -- Companies insertion')
  if Company.new(sei: 0).save
    (1..5).each do |sei|
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
    ## APOIO A EMPRESAS CATEGORIES
    ############
    category = Category.new(name: 'Orientações básicas sobre a estratégia e-SUS AB',
                            severity: :low, system: :from_call).save!
    category = Category.new(name: 'Orientações básicas sobre a utilização do sistema',
                            severity: :low, system: :from_call).save!
    category = Category.new(name: 'Instalação do Sistema',
                            severity: :low, system: :from_call).save!
    category = Category.new(name: 'Gerenciamento do cadastro do cidadão',
                            severity: :medium, system: :from_call).save!

    #########
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

    ###############
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

    ## SOLUCAO DE CONTROVERSIAS CATEGORIES
    ##################
    category = Category.new(name: 'Hardware',
                            severity: :low, system: :from_controversy).save!
    category = Category.new(name: 'Software',
                            severity: :low, system: :from_controversy).save!
  rescue StandardError
    Rails.logger.error('ERROR creating a CATEGORY')
    Rails.logger.error(category.errors.full_messages)
  end
  Rails.logger.info('[FINISH] -- Categories insertion')
end

def seed_answers
  categories = Category.all
  allowed_users = User.where(role: %w[call_center_admin call_center_user])
  Rails.logger.info('[START]  -- Answers (and FAQ) insertion')
  (1..50).each do |_|
    system_id = System.all.sample.id
    category = system_id.zero? ? categories.from_call.sample : categories.from_controversy.sample
    answer = Answer.new(question: Faker::Lorem.sentence(50, true, 6),
                        answer: Faker::Lorem.sentence(50, true, 6),
                        category: category,
                        user: allowed_users.sample,
                        faq: Random.rand > 0.90,
                        keywords: Faker::Lorem.sentence(1, true, 3),
                        system: system_id)
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
  unities = Unity.all
  categories = Category.all
  access_profiles = %w[Médico Enfermeiro Administrador Secretário]

  Rails.logger.info('[START]  -- Calls insertion')
  (1..20).each do |_|
    ubs = unities.sample
    city = ubs.city
    contract = city.contract
    user = User.where(company: contract.company).sample
    protocol = 0.seconds.from_now.strftime('%Y%m%d%H%M%S%L').to_i
    call = Call.new(title: Faker::Lorem.sentence(15, true, 2),
                    description: Faker::Lorem.sentence(80, true, 6),
                    version: ['1.0.0', '1.0.1', '2.0.0', '3.0.0-beta'].sample,
                    access_profile: access_profiles.sample,
                    feature_detail: %w[Impressão Login Consulta FAQ].sample,
                    severity: Call.severities.keys.sample,
                    status: Call.statuses.keys.sample,
                    protocol: protocol,
                    city: city,
                    category: categories.sample,
                    sei: contract.sei,
                    user: user,
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

def seed_controversies
  cities = City.all

  Rails.logger.info('[START]  -- Controversy insertion')
  (1..20).each do |_|
    city = cities.sample
    unity = city.unities.sample
    contract = city.contract
    company = contract.company
    user = company.users.sample
    protocol = 0.seconds.from_now.strftime('%Y%m%d%H%M%S%L').to_i
    controversy = Controversy.new(id: protocol,
                                  title: Faker::Lorem.sentence(15, true, 2),
                                  description: Faker::Lorem.sentence(80, true, 6),
                                  status: Controversy.statuses.keys.sample,
                                  protocol: protocol,
                                  city: city,
                                  unity: unity,
                                  company: company,
                                  creator: user,
                                  company_user: user,
                                  category: Category.all.sample,
                                  city_user: User.from_city(city.id).sample,
                                  unity_user: Random.rand > 0.6 ? unity.try(:users).try(:sample) : nil)
    if controversy.save
      Rails.logger.debug('Inserted a new controversy')
      seed_feedback(controversy) if controversy.closed?
    else
      Rails.logger.error('ERROR creating a CONTROVERSY')
      Rails.logger.error(controversy.errors.full_messages)
    end
  end
  Rails.logger.info('[FINISH] -- Controversies insertion')
end

def seed_feedback(controversy)
  feedback = Feedback.new(description: Faker::Lorem.sentence(150, true, 6),
                          controversy_id: controversy.id)
  if feedback.save
    Rails.logger.debug("Inserted a new feedback for controversy #{controversy.protocol}")
  else
    Rails.logger.error('ERROR creating a FEEDBACK')
    Rails.logger.error(feedback.errors.full_messages)
  end
end

def seed_events
  calls = Call.all
  controversies = Controversy.all
  call_center_users = User.where(role: %w[call_center_admin call_center_user])
  company_users = User.where(role: %w[company_admin company_user])
  city_users = User.where(role: %w[city_admin])
  unity_users = User.where(role: %w[ubs_admin ubs_user])

  Rails.logger.info('[START]  -- Events (and FAQ) insertion')
  (1..200).each do |_|
    random_user = Random.rand
    type_id = Random.rand > 0.5 ? 1 : 2 # Alteration or Reply

    if Random.rand > 0.5 # Call
      user = random_user > 0.60 ? call_center_users.sample : company_users.sample
      protocol = calls.sample.id

      event = Event.new(user: user,
                        protocol: protocol,
                        type_id: type_id,
                        system_id: 1)

      if event.save
        Rails.logger.debug("Inserted a new #{type_id} event to Call -> #{event.protocol}")
        type_id == 1 ? create_alteration(event.id) : create_reply(event.id)
      else
        Rails.logger.error('ERROR creating an EVENT')
        Rails.logger.error(event.errors.full_messages)
      end

    else # Controversy
      user = if random_user < 0.25
               call_center_users.sample
             elsif random_user < 0.5
               company_users.sample
             elsif random_user < 0.75
               city_users.sample
             else
               unity_users.sample
             end
      protocol = controversies.sample.id

      event = Event.new(user: user,
                        protocol: protocol,
                        type_id: type_id,
                        system_id: 2)

      if event.save
        Rails.logger.debug("Inserted a new #{type_id} event to Controversy -> #{event.protocol}")
        type_id == 1 ? create_alteration(event.id) : create_reply(event.id)
      else
        Rails.logger.error('ERROR creating an EVENT')
        Rails.logger.error(event.errors.full_messages)
      end
    end
  end

  Rails.logger.info('[FINISH] -- Events insertion')
end

def create_alteration(id)
  alteration = Alteration.new(
    id: id,
    type: Alteration.types.keys.sample
  )

  if alteration.save
    Rails.logger.debug("Inserted a new alteration to -> #{id}")
  else
    Rails.logger.error('ERROR creating an ALTERATION')
    Rails.logger.error(alteration.errors.full_messages)
  end
end

def create_reply(id)
  reply = Reply.new(
    id: id,
    faq: 'N',
    description: Faker::Lorem.sentence(20, true, 6)
  )

  if reply.save
    Rails.logger.debug("Inserted a new reply to -> #{id}")
  else
    Rails.logger.error('ERROR creating a REPLY')
    Rails.logger.error(reply.errors.full_messages)
  end
end

def seed_faq_from_replies(call, reply)
  system_id = reply.repliable_type == 'Call' ? 1 : 2
  answer = Answer.new(question: call.title,
                      answer: reply.description,
                      category_id: call.category_id,
                      user: reply.user,
                      faq: true,
                      system_id: system_id,
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
  seed_systems
  seed_event_types
  seed_companies
  seed_users
  seed_states
  seed_cities
  seed_unities
  seed_categories
  seed_answers
  seed_calls
  seed_controversies
  seed_events
  Rails.logger.warn('[FINISH] SEED')
end

main
