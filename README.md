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

Then head over to [Code Corps](https://codecorps.org), where we manage contributions.

## Developer installation guide

### Recommended install

To make your life easier, you can just clone this repository and use our Vagrant development box. [Follow this guide to get started.](docs/DEFAULT_INSTALL.md)

#### Custom install

We wholeheartedly recommend against doing a custom install. You'll be spending more time configuring and less time being productive. But if you'd like to work that way, you can read our [custom install guide](docs/CUSTOM_INSTALL.md).

### Working with Ember

The Code Corps API is intended to work alongside a client written in Ember. For that purpose, the Rails application exposes all of its API endpoints behind an `api.` subdomain.

On the Ember client side of things, we use [`ember-cli-deploy`](https://github.com/ember-cli/ember-cli-deploy) with a `redis` plugin to deploy the client application to redis. Multiple revisions are maintained this way.

Any server request pointing to the main domain and not the `api.` subdomain is redirected to the API's `ember_index_controller#index`. There, depending on the remainder of the request path and the current environment, a specific revision of the Ember app's `index.html` is retrieved from redis and rendered. This `index.html` can be:
* the development revision, if the current environment is development
* a specific deployed revision in production if the request contains a revision parameter in SHORT_UUID format
* the latest deployed revision in production if the request does not contain a revision parameter
* a plain text string containing "INDEX NOT FOUND" if a revision was specified, but the key for the specified revision was not found by redis


### Debugging the API

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
$ bundle exec pry-remote
```

## Built with

- [Rails::API](https://github.com/rails-api/rails-api) — Our backend API is a Rails::API app which uses JSON API to respond RESTfully to requests.
- [Ember.js](https://github.com/emberjs/ember.js) — Our frontend is an Ember.js app that communicates with the Rails API.
- [PostgreSQL](http://www.postgresql.org/) — Our primary data store uses Postgres.
