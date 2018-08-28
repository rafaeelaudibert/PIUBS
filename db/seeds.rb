# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'faker'
require 'logger'
require 'cpf_cnpj'

Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::INFO # Options for logger.level DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN

def seed_users
  User.roles.each do |_role|
    _role_name = _role[0]
    _role_id = _role[1]
    _email = _role_name + '@piubs.com'
    _passwd = 'changeme'
    _cpf = CPF.generate
    new_user = User.new(cpf: _cpf, name: _role_name, email: _email, password: _passwd, password_confirmation: _passwd, role: _role_name)
    if new_user.save
      Rails.logger.info("User #{_email} was created successfuly!")
    else
      Rails.logger.error("Error creating user #{_email}!")
    end
  end
end

def seed_user(company)
  _role_name = 'company_admin'
  _email = "company_admin_#{company.sei}@piubs.com"
  _passwd = 'changeme'
  _cpf = CPF.generate
  new_user = User.new(cpf: _cpf, name: _role_name, email: _email, password: _passwd, password_confirmation: _passwd, role: _role_name)
  if new_user.save
    Rails.logger.info("Company USER ADMIN #{_email} was created successfuly!")
  else
    Rails.logger.error("Error creating Company USER ADMIN #{_email}!")
  end
end

def seed_unity(cnes, name, city)
  ubs = Unity.new('cnes' => cnes, 'name' => name, 'city' => city)
  if ubs.save
    Rails.logger.debug("INSERTED a UNITY in #{city.name}: #{name}")
  else
    Rails.logger.error("ERROR inserting UNITY in #{city.name}: #{name}")
  end
end

def seed_city(city_name, state)
  city = City.new('name' => city_name, 'state_id' => state.id)
  if city.save
    Rails.logger.debug("INSERTED a CITY in #{state.name}: #{city_name}")
    (1..10).each do |_num|
      _cnes = "#{city.id}#{_num}"
      _ubs_name = "Unidade Básica de Saúde #{city_name} - #{_num}"
      seed_unity(_cnes, _ubs_name, city)
    end
    seed_contract(city)
  else
    Rails.logger.error("ERROR inserting CITY in #{state.name}: #{city_name}")
  end
end

def seed_states
  JSON(IO.binread('./public/cities.json')).each do |_estado|
    state = State.new('name' => _estado['nome'])
    if state.save
      Rails.logger.info("INSERTED a STATE in the database: #{_estado['nome']}")
      Rails.logger.info('Started seeding their cities...')
      _estado['cidades'].each do |_city|
        seed_city(_city, state)
      end
      Rails.logger.info('Finished')
    else
      Rails.logger.error("ERROR inserting STATE #{_estado['nome']}")
    end
  end
end

def seed_contract(city)
  sei = rand(1..20)
  contract = Contract.new('sei' => sei, 'city' => city, 'contract_number' => "#{sei}#{city.id}")
  if contract.save
    Rails.logger.debug("INSERTED a CONTRACT in the database: #{sei}#{city.id}")
  else
    Rails.logger.error("ERROR inserting CONTRACT: #{sei}#{city.id}")
  end
end

def seed_companies
  (1..20).each do |_sei|
    company = Company.new('sei' => _sei)
    if company.save
      Rails.logger.info("INSERTED a COMPANY in the database: #{_sei}")
      seed_user(company)
    else
      Rails.logger.error("ERROR inserting COMPANY #{_sei}")
    end
  end
end

def seed_categories
  %w[Hardware Software Outro].each do |_category|
    category = Category.new("name": _category)
    if category.save
      Rails.logger.info("Inserted a new category: #{_category}")
    else
      Rails.logger.error('ERROR creating a CATEGORY')
    end
  end
end

def seed_faq
  quantity = 10_000
  Rails.logger.info("Starting to insert #{quantity} answers...")
  (1..quantity).each do |_|
    q = Answer.new('question': Faker::Lorem.sentence(50, true, 6),
                   'answer': Faker::Lorem.sentence(50, true, 6),
                   'category_id': 1,
                   'user': User.find(1),
                   'faq': true)
    if q.save
      Rails.logger.debug('Inserted a new answer')
    else
      Rails.logger.error('ERROR creating an ANSWER')
    end
  end
  Rails.logger.info('Finished')
end

def main
  Rails.logger.warn('SEED STARTED')
  seed_users
  seed_companies
  seed_states
  seed_categories
  seed_faq
  Rails.logger.warn('SEED FINISHED')
end

main
