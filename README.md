# Candyfair

The fairest way to distribute candy!

## How to Develop

Install PostgreSQL, e.g., `brew install postgres`.

    bundle install
    cp dotenv.development .env

Update `.env` with details about your database.

    bin/rake db:create db:migrate db:seed
    foreman start

## How to Deploy to Heroku

Create your app on Heroku, then add the `heroku` git remote.

    heroku config:set DEFAULT_USER=desired_default_username
    heroku config:set DEFAULT_PASSWORD=desired_default_account_password
    git push heroku master
    heroku ps:scale web=1
    heroku run bin/rake db:migrate db:seed
