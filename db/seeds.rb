# encoding: UTF-8
puts 'Seeding user...'
user = User.create!(username: ENV['DEFAULT_USER'],
                    password: ENV['DEFAULT_PASSWORD'],
                    password_confirmation: ENV['DEFAULT_PASSWORD'])
puts "\tSeeded user #{user.username} with password #{ENV['DEFAULT_PASSWORD']}"

puts 'Seeding candy'
[
  'Twix', 'Starburst', 'Whoppers', 'MilkyWay', 'Snickers', 'Kit Kat',
  'Skittles', 'Bottle Caps', 'Circus Peanuts', 'Heath', 'Almond Joy',
  'Twizzlers', 'Mounds', "Reese's Cups", "Reese's Pieces", 'SweeTarts',
  'Sour Patch Kids', 'Jolly Rancher', 'AirHeads', '100 Grand', 'M&Ms',
  'LifeSavers', '3 Musketeers', 'Milk Duds', 'Butterfinger', 'Candy Corn',
  'Toblerone', 'Nerds', 'LaffyTaffy', "Hershey's Kisses", 'Tootsie Roll',
  'Swedish Fish', 'Pixy Stix', 'Nestlé Crunch'
].each do |name|
  Candy.create!(name: name)
end

puts 'Seeding people'
[
  'Sarah', 'Summer', 'Todd', 'Nick', 'Chase S', 'Chase J', 'David', 'Dave',
  'Mklbtz', 'Michael H', 'Erik', 'Graham', 'Lindsay', 'Heather', 'Tristan'
].each do |name|
  Person.create!(name: name, created_by_user: user)
end

puts 'Seeding preferences'
{
  'Sarah' => {
    'Like' => ['Kit Kat'],
    'Hate' => ['Circus Peanuts', 'LaffyTaffy'],
    'Love' => ['MilkyWay', 'Swedish Fish'],
    'Dislike' => ['Heath']
  }
}.each do |person_name, preferences|
  person = Person.find_by_name(person_name)
  preferences.each do |type, candy_names|
    candy_names.each do |candy_name|
      Preference.create!(person: person, type: type,
                         candy: Candy.find_by_name(candy_name))
    end
  end
end
