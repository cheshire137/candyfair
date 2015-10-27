# Candyfair

The fairest way to distribute candy!

## How to Develop

Install PostgreSQL, e.g., `brew install postgres`.

    bundle install
    cp dotenv.development .env

Update `.env` with details about your database.

    bin/rake db:create db:migrate db:seed
    bin/rails s
