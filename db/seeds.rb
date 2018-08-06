# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user = CreateAdminService.new.call
puts 'CREATED ADMIN USER: ' << user.email

estados = (CS.states :br).sort_by { |a| a[1] }
estados.each do |_sigla, _state|
  _state = 'Distrito Federal' if _state == 'Federal District'
  state = State.new('name' => _state)
  puts `INSERTED a STATE in the database: #{_state}` if state.save

  cidades = CS.cities _sigla
  cidades.each do |_city|
    city = City.new('name' => _city, 'state_id' => state.id)
    puts `INSERTED a CITY in #{_state}: #{_city}` if city.save
  end
end
