puts 'Seeding CirrusMio user'
cirrusmio_user = User.create!(username: 'CirrusMio', password: 'cirrusmio',
                              password_confirmation: 'cirrusmio')
