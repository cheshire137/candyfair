# Candyfair

The fairest way to distribute candy!

## How to Develop

Install PostgreSQL, e.g., `brew install postgres`.

    cp dotenv.development .env

Update .env with details about your database.

    bundle install
    bin/rake db:create db:migrate
    bin/rails s
