# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'logger'
require 'csv'

Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::INFO # Options for logger.level DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN

# Creates the users, except company_admin and company_user ones
def seed_users
  if Company.new(sei: 0).save
    admin = User.new(cpf: CPF.generate, name: 'Admin Master', email: 'admin@piubs.com', password: '19550410', password_confirmation: '19550410', role: 'admin', sei: 0)
    if admin.save
      Rails.logger.info('[INFO]   -- Created ADMIN MASTER USER!')
    else
      Rails.logger.fatal('[ERROR]  -- Error creating ADMIN MASTER USER!')
      Rails.logger.error(admin.errors)
      raise
    end
  end
end

def seed_states
  Rails.logger.info('[START]  -- States insertion')
  CSV.foreach('./public/csv/estados.csv', headers: true) do |row|
    state = State.new(name: row['Und Fed'].titleize, abbr: row['UF'], id: row['COD UF'])
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
    city = City.new(name: row['NOME MUNIC'], state_id: row['COD UF'], id: row['CodMun'][0...-1])
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
    _name = row['nom_estab'] ? row['nom_estab'].titleize : row['nom_estab']
    _address = row['dsc_endereco'] ? row['dsc_endereco'].titleize : row['dsc_endereco']
    _neighborhood = row['dsc_bairro'] ? row['dsc_bairro'].titleize : row['dsc_bairro']
    _phone = row['dsc_telefone'] == 'Não se aplica' ? '' : row['dsc_telefone']
    unity = Unity.new(cnes: row['cod_cnes'], name: _name, city_id: row['cod_munic'], address: _address, neighborhood: _neighborhood, phone: _phone)
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
  %w[Hardware Software Outro].each do |_category|
    category = Category.new(name: _category)
    if category.save
      Rails.logger.debug("[DEBUG]  -- Inserted a new category: #{_category}")
    else
      Rails.logger.error('[ERROR]  -- ERROR creating a CATEGORY')
      Rails.logger.error(category.errors.full_messages)
    end
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
