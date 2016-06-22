# Code Corps Rails API

![Code Corps Rails Logo](https://d3pgew4wbk2vb1.cloudfront.net/images/github/code-corps-rails.png)

[![Circle CI](https://circleci.com/gh/code-corps/code-corps-api.svg?style=svg)](https://circleci.com/gh/code-corps/code-corps-api) [![Dependency Status](https://gemnasium.com/code-corps/code-corps-api.svg)](https://gemnasium.com/code-corps/code-corps-api) [![Code Climate](https://codeclimate.com/github/code-corps/code-corps-api/badges/gpa.svg)](https://codeclimate.com/github/code-corps/code-corps-api) [![Test Coverage](https://codeclimate.com/github/code-corps/code-corps-api/badges/coverage.svg)](https://codeclimate.com/github/code-corps/code-corps-api/coverage) [![Inline docs](http://inch-ci.org/github/code-corps/code-corps-api.svg?branch=develop)](http://inch-ci.org/github/code-corps/code-corps-api) [![Slack Status](http://slack.codecorps.org/badge.svg)](http://slack.codecorps.org)

The Code Corps API is an open source Rails::API backend that powers the Code Corps platform. It includes:

- developer and project matchmaking
- project management tooling
- a donations engine that distributes donations to projects

Contributing
------------

We'd love to have you contribute to Code Corps directly!

To do so, please read the guidelines in our [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Developer installation guide

### Install Rails, PostgreSQL, Redis, and ElasticSearch

We need to install the Ruby on Rails framework, the PostgreSQL database, and the Redis data store.

1. [Install Rails](http://installrails.com/).
2. Install and configure PostgreSQL 9.3+.
  1. Run `postgres -V` to see if you already have it.
  2. Make sure that the server's messages language is English; this is [required](https://github.com/rails/rails/blob/3006c59bc7a50c925f6b744447f1d94533a64241/activerecord/lib/active_record/connection_adapters/postgresql_adapter.rb#L1140) by the ActiveRecord Postgres adapter.
3. Install and make sure you can run redis:
   * Follow the [official quickstart guide](http://redis.io/topics/quickstart)
   * It's best to install it as a service instead of running it manually
   * To make sure everything works and the service is running, execute `redis-cli ping` in the console. It should respond with `PONG`
4. Install ElasticSearch
   * On Mac, run `brew install elasticsearch`
   * Or for Linux or Windows, consult the [setup guide](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html)

### Clone this git repository

You'll want to [clone this repository](https://help.github.com/articles/cloning-a-repository/) with `git clone https://github.com/code-corps/code-corps-api.git`.

### Set up the Rails app

1. Run `bin/setup` to set up and seed the database.
2. Try running the specs: `bundle exec rake spec`

From here, we need to start the web server, Redis, and Sidekiq processes. You can either:

#### Use [foreman](https://github.com/ddollar/foreman) to run your application's processes
3. Stop your existing `redis-server` process
4. Run the api with `foreman start -f Procfile.dev`. This will start any service listed in that Procfile.

#### Alternatively, run your application's processes individually
3. You already have `redis-server` running. In the future, you'll need to run it, as well.
4. Start Sidekiq with `bundle exec sidekiq`
5. Start the Rails server with `rails s`


### To make sure the API is running properly

Point your browser (or make a direct request) to http://api.lvh.me:3000/ping. There should be a `{"ping":"pong"}` response from it.


### Working with Ember

The CodeCorps API is intended to work alongside a client written in Ember. For that purpose, the rails application exposes all of it's API endpoints behind an `api.` subdomain.

On the Ember client side of things, we use [`ember-cli-deploy`](https://github.com/ember-cli/ember-cli-deploy) with a `redis` plugin to deploy the client application to redis. Multiple revisions are maintained this way.

Any server request pointing to the main domain and not the `api.` subdomain is redirected to `ember_index_controller#index`. There, depending on the remainder of the request path and the current environment, a specific revision of the ember app is retrieved from redis and rendered. This can be
* the development revision, if the current environment is development
* a specific deployed revision in production if the request contains a revision parameter in SHORT_UUID format
* the latest deployed revision in production if the request does not contain a revision parameter
* A plain text string containing "INDEX NOT FOUND" if a revision was specified, but the key for the specified revision was not found by redis


### Debugging the API

Because the app is running foreman, debugging use `pry` won't work the same way. If you want to use `pry`, you'll need to [debug remotely](https://github.com/nixme/pry-debugger#remote-debugging).

Add `binding.remote_pry` where you want to pause:

```ruby
class UsersController < ApplicationController
  def index
    binding.remote_pry
    ...
  end
end
```

Load a page that triggers the code. Connect to the session:

```
$ bundle exec pry-remote
```


## Built with

- [Rails::API](https://github.com/rails-api/rails-api) — Our backend API is a Rails::API app which uses JSON API to respond RESTfully to requests.
- [Ember.js](https://github.com/emberjs/ember.js) — Our frontend is an Ember.js app that communicates with the Rails API.
- [PostgreSQL](http://www.postgresql.org/) — Our primary data store uses Postgres.
