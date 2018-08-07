# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = CreateAdminService.new.call
puts 'CREATED ADMIN USER: ' << user.email

# Insert cities and states
JSON(IO.binread('./public/cities.json')).each do |_estado|
  state = State.new('name' => _estado['nome'])
  puts `INSERTED a STATE in the database: #{_estado['nome']}` if state.save

  _estado['cidades'].each do |_city|
    city = City.new('name' => _city, 'state_id' => state.id)
    puts `INSERTED a CITY in #{_estado['nome']}: #{_city}` if city.save
  end
end
