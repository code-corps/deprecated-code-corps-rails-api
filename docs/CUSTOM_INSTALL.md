## Custom developer installation guide

We really recommend using our Vagrant developer box as your default. [Read those guides](docs/DEFAULT_INSTALL.md) and see how much shorter they are. :)

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
5. Install ImageMagik
   * On Mac, run `brew install imagemagick`
   * Or for Linux or Windows, consult the [guide](http://www.imagemagick.org/script/binary-releases.php)

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

### Add virtual hosts

You'll need to point `api.codecorps.dev`, `codecorps.dev`, and `www.codecorps.dev` to `api.lvh.me` for the Ember app to work.


### To make sure the API is running properly

Point your browser (or make a direct request) to http://api.lvh.me:5000/ping. There should be a `{"ping":"pong"}` response from it.
