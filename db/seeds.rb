# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Options for logger.level DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
require 'logger'
Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::WARN

def seed_users()
  User.roles.each do |_role|
    _role_name, _role_id, _email, _passwd = _role[0], _role[1], _role[0]+'@piubs.com', 'changeme'
    new_user = User.new(:name => _role_name, :email => _email, :password => _passwd, :password_confirmation => _passwd, :role => _role_name)
    if new_user.save
      Rails.logger.info("User #{_email} was created successfuly!")
    else
      Rails.logger.error("Error creating user #{_email}!")
    end
  end
end

def seed_user(company)
  _role_name, _email, _passwd = "company_admin", "company_admin_#{company.sei}@piubs.com", 'changeme'
  new_user = User.new(:name => _role_name, :email => _email, :password => _passwd, :password_confirmation => _passwd, :role => _role_name)
  if new_user.save
    Rails.logger.info("Company USER ADMIN #{_email} was created successfuly!")
  else
    Rails.logger.error("Error creating Company USER ADMIN #{_email}!")
  end
end

def seed_unity(cnes, name, city)
  ubs = Unity.new('cnes' => cnes, 'name' => name, 'city' => city)
  if ubs.save
    Rails.logger.info("INSERTED a UNITY in #{city.name}: #{name}")
  else
    Rails.logger.error("ERROR inserting UNITY in #{city.name}: #{name}")
  end
end

def seed_city(city_name, state)
  city = City.new('name' => city_name, 'state_id' => state.id)
  if city.save
    Rails.logger.info("INSERTED a CITY in #{state.name}: #{city_name}")
    (1..10).each do |_num|
      _cnes, _ubs_name = "#{city.id}#{_num}", "Unidade Básica de Saúde #{city_name} - #{_num}"
      seed_unity(_cnes,_ubs_name, city)
    end
    seed_contract(city)
  else
    Rails.logger.error("ERROR inserting CITY in #{state.name}: #{city_name}")
  end
end

def seed_states()
  JSON(IO.binread('./public/cities.json')).each do |_estado|
    state = State.new('name' => _estado['nome'])
    if state.save
      Rails.logger.info("INSERTED a STATE in the database: #{_estado['nome']}")
      _estado['cidades'].each do |_city|
        seed_city(_city, state)
      end
    else
      Rails.logger.error("ERROR inserting STATE #{_estado['nome']}")
    end
  end
end

def seed_contract(city)
  sei = rand(20)+1
  contract = Contract.new('sei' => sei , 'city' => city, 'contract_number' => "#{sei}#{city.id}")
  if contract.save
    Rails.logger.info("INSERTED a CONTRACT in the database: #{sei}#{city.id}")
  else
    Rails.logger.error("ERROR inserting CONTRACT: #{sei}#{city.id}")
  end
end

def seed_companies()
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

def main()
  Rails.logger.warn("Seed started")
  seed_users
  seed_companies
  seed_states
  Rails.logger.warn("Seed Finished")
end

main
