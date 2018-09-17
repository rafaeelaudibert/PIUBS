# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'faker'
require 'logger'
require 'cpf_cnpj'
require 'csv'

Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::INFO # Options for logger.level DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN

# Creates the users, except company_admin and company_user ones
def seed_users
  Rails.logger.info('[START]  -- Users insertion')

  if User.new(cpf: CPF.generate, name: 'Admin Master', email: 'admin@piubs.com', password: 'changeme', password_confirmation: 'changeme', role: 'admin', sei: 0).save
    User.roles.each do |_role|
      next if _role[0] == 'admin' || _role[0] == 'company_admin' || _role[0] == 'company_user' # Prevent from creating this, as they will be already created later or have already been created
      _role_name = _role[0]
      _role_id = _role[1]
      _email = _role_name + '@piubs.com'
      _passwd = 'changeme'
      user = User.new(cpf: CPF.generate, name: _role_name.capitalize, email: _email, password: _passwd, password_confirmation: _passwd, role: _role_name)
      if user.save
        Rails.logger.debug("User #{_email} was created successfuly!")
      else
        Rails.logger.error("Error creating user #{_email}!")
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
  _email = "#{role_name}_#{company.sei}@piubs.com"
  user = User.new(sei: company.sei, cpf: CPF.generate, name: role_name, email: _email, password: 'changeme', password_confirmation: 'changeme', role: role_name)
  if user.save
    Rails.logger.debug("User #{_email} was created successfuly!")
  else
    Rails.logger.error("Error creating user #{_email}!")
    Rails.logger.error(user.errors.full_messages)
  end
end

def seed_unity(cnes, name, city)
  ubs = Unity.new('cnes' => cnes, 'name' => name, 'city' => city)
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
    state = State.new(name: row['Und Fed'].titleize, abbr: row['UF'], id: row['COD UF'])
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
    city = City.new(name: row['NOME MUNIC'], state_id: row['COD UF'], id: row['CodMun'][0...-1])
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
    _name = row['nom_estab'] ? row['nom_estab'].titleize : row['nom_estab']
    _address = row['dsc_endereco'] ? row['dsc_endereco'].titleize : row['dsc_endereco']
    _neighborhood = row['dsc_bairro'] ? row['dsc_bairro'].titleize : row['dsc_bairro']
    _phone = row['dsc_telefone'] == 'Não se aplica' ? '' : row['dsc_telefone']
    unity = Unity.new(cnes: row['cod_cnes'], name: _name, city_id: row['cod_munic'], address: _address, neighborhood: _neighborhood, phone: _phone)
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
  contract = Contract.new(sei: sei,
                          city: city,
                          contract_number: "#{sei}#{city.id}",
                          filename: 'contrato.pdf',
                          content_type: 'application/pdf',
                          file_contents: IO.read(File.join(Rails.root, 'public', 'assets', 'documents', 'contrato.pdf'), mode: 'rb'))
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
    (1..20).each do |_sei|
      company = Company.new(sei: _sei)
      if company.save
        Rails.logger.debug("INSERTED a COMPANY in the database: #{_sei}")
        seed_company_user company, 'company_admin'
        seed_company_user company, 'company_user'
      else
        Rails.logger.error("ERROR inserting COMPANY #{_sei}")
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
  %w[Hardware Software Outro].each do |_category|
    category = Category.new(name: _category)
    if category.save
      Rails.logger.debug("Inserted a new category: #{_category}")
    else
      Rails.logger.error('ERROR creating a CATEGORY')
      Rails.logger.error(category.errors.full_messages)
    end
  end
  Rails.logger.info('[FINISH] -- Categories insertion')
end

def seed_answers
  quantity = 2_000
  categories = Category.all
  allowedUsers = User.where(role: %w[call_center_admin call_center_user])
  Rails.logger.info('[START]  -- Answers (and FAQ) insertion')
  (1..quantity).each do |_|
    answer = Answer.new(question: Faker::Lorem.sentence(50, true, 6),
                        answer: Faker::Lorem.sentence(50, true, 6),
                        category_id: categories.sample.id,
                        user: allowedUsers.sample,
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
  quantity = 300
  unities = Unity.all
  categories = Category.all
  Rails.logger.info('[START]  -- Calls insertion')
  (1..quantity).each do |_|
    _ubs = unities.sample
    _city = City.find(_ubs.city_id)
    _contract = Contract.where(city_id: _city.id).first
    _user = User.where(sei: _contract.sei).sample
    _protocol = Time.now.strftime('%Y%m%d%H%M%S%L').to_i
    call = Call.new(title: Faker::Lorem.sentence(15, true, 2),
                    description: Faker::Lorem.sentence(80, true, 6),
                    version: ['1.0.0', '1.0.1', '2.0.0', '3.0.0-beta'].sample,
                    access_profile: %w[Médico Enfermeiro Administrador Secretário].sample,
                    feature_detail: %w[Impressão Login Consulta FAQ].sample,
                    severity: Call.severities.keys.sample,
                    status: Call.statuses.keys.sample,
                    protocol: _protocol,
                    city_id: _city.id,
                    category_id: categories.sample.id,
                    state_id: _city.state_id,
                    sei: _contract.sei,
                    user_id: _user.id,
                    id: _protocol,
                    cnes: _ubs.cnes)
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
  categories = Category.all
  Rails.logger.info('[START]  -- Replies (and FAQ) insertion')
  (1..quantity).each do |_|
    user = Random.rand > 0.7 ? User.where(role: %w[call_center_admin call_center_user]).sample : User.where(role: %w[company_admin company_user]).sample
    call = calls.sample
    reply = Reply.new(protocol: call.protocol,
                      description: Faker::Lorem.sentence(25, true, 0),
                      user_id: user.id,
                      status: [0, 1, 2].sample,
                      category: user.role == 'company_admin' || user.role == 'company_user' ? 'reply' : 'support',
                      faq: user.role == 'company_admin' || user.role == 'company_user' ? false : Random.rand > 0.90)
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

def seed_faq_from_replies(_call, _reply)
  answer = Answer.new(question: _call.title,
                      answer: _reply.description,
                      category_id: _call.category_id,
                      user: _reply.user,
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
