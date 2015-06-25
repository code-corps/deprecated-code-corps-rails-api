# Code Corps Rails API

[![Code Climate](https://codeclimate.com/github/code-corps/code-corps-api/badges/gpa.svg)](https://codeclimate.com/github/code-corps/code-corps-api) [![Test Coverage](https://codeclimate.com/github/code-corps/code-corps-api/badges/coverage.svg)](https://codeclimate.com/github/code-corps/code-corps-api/coverage)

The Code Corps API is an open source Rails::API backend that powers the Code Corps platform. It includes:

- developer and project matchmaking
- project management tooling
- a donations engine that distributes donations to projects

## Developer installation guide

### First steps

1. Install and configure PostgreSQL 9.3+.
  1. Run `postgres -V` to see if you already have it.
  1. Make sure that the server's messages language is English; this is [required](https://github.com/rails/rails/blob/3006c59bc7a50c925f6b744447f1d94533a64241/activerecord/lib/active_record/connection_adapters/postgresql_adapter.rb#L1140) by the ActiveRecord Postgres adapter.
2. Install Ruby 2.2.1 and Bundler.
3. Clone the project and bundle.

### Before you start Rails

1. `bundle install`
2. `bundle exec rake db:create db:migrate db:test:prepare`
3. Try running the specs: `bundle exec rake spec`
4. `bundle exec rails server`

## Built with

- [Rails::API](https://github.com/rails-api/rails-api) — Our backend API is a Rails::API app which uses JSON API to respond RESTfully to requests.
- [Ember.js](https://github.com/emberjs/ember.js) — Our frontend is an Ember.js app that communicates with the Rails API.
- [PostgreSQL](http://www.postgresql.org/) — Our primary data store uses Postgres.
