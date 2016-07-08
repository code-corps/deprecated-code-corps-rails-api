### Interacting with the app

You'll notice we wrapped `docker-compose` earlier, but you'll generally want to use this to interact with the app.

- `bundle exec rails console` → `docker-compose run web rails console`
- `bundle exec rake db:migrate` → `docker-compose run web rake db:migrate`
- `bundle exec rake db:test:prepare` → `docker-compose run web rake db:test:prepare`
- and so on...

We do have a couple other helper scripts:

- `bin/setup` → sets up the app
- `bin/migrate` → migrates your database
- `bin/reseed` → re-runs `rake db:seed_fu` to re-seed your database


### Guard and tests

You'll also notice that the `test` container we mentioned above is running `guard`. This means that file changes will be observed and tests re-run on those files.

You can certainly run `docker-console run test rspec spec`, but `guard` can help you by constantly watching for failing specs.


### Stopping and starting the server

Need to stop the containers? Either `Ctrl+C` or in a seperate prompt run `docker-compose stop`.

To start the services again you can run `docker-compose up`, or `docker-compose start` to start the containers in a detached state.


### Rebuilding Docker containers

If you ever need to rebuild you can run `docker-compose up --build`. Unless you've destroyed your Docker container images, this should be faster than the first run.


### Pushing changes

You can use `git` as you normally would, either on your own host machine or in Docker's `web` container.


### Serving Ember

The Code Corps API is intended to work alongside a client written in Ember. For that purpose, the Rails application exposes all of its API endpoints behind an `api.` subdomain.

On the Ember client side of things, we use [`ember-cli-deploy`](https://github.com/ember-cli/ember-cli-deploy) with a `redis` plugin to deploy the client application to redis. Multiple revisions are maintained this way.

Any server request pointing to the main domain and not the `api.` subdomain is redirected to the API's `ember_index_controller#index`. There, depending on the remainder of the request path and the current environment, a specific revision of the Ember app's `index.html` is retrieved from redis and rendered. This `index.html` can be:
* the development revision, if the current environment is development
* a specific deployed revision in production if the request contains a revision parameter in SHORT_UUID format
* the latest deployed revision in production if the request does not contain a revision parameter
* a plain text string containing "INDEX NOT FOUND" if a revision was specified, but the key for the specified revision was not found by redis


### Debugging

Because the app is running `foreman`, debugging using `pry` won't work the same way. If you want to use `pry`, you'll need to [debug remotely](https://github.com/nixme/pry-debugger#remote-debugging).

Add `binding.remote_pry` where you want to pause:

```ruby
class UsersController < ApplicationController
  def index
    binding.remote_pry
    ...
  end
end
```

Load a page or make a request that triggers the code. Connect to the session:

```shell
$ docker-compose run web pry-remote
```
