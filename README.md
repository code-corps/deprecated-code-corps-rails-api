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

Then check out some GitHub issues to see where you can help out.

## Installing

To make your life easier, you can just clone this repository and use our Docker container. [Follow this guide to get started.](docs/INSTALLING.md)

## Usage

Have everything installed and ready to work? [Read our usage guides](docs/USAGE.md) to learn how to:

- Run normal Rails commands through Docker
- Run tests
- Stop and start the server, and rebuild Docker containers
- Push changes to GitHub
- Serve the Ember app's `index.html`
- Debug with `pry-remote`

## API Docs

You can generate documentation by navigating into the `/blueprint` directory.

If installing for the first time, run:

```shell
docker-compose build
```

Then start the `aglio` service with:

```shell
docker-compose up
```

Now you can generate the docs with our shell script:

```bash
./generate
```

You should be able to view the docs by opening the newly generated `index.html` in your browser.

If you're developing with [Atom](https://atom.io/), you can also use the [API Blueprint Preview](https://atom.io/packages/api-blueprint-preview) package to preview your blueprint changes in realtime.

## Built with

- [Rails](http://edgeguides.rubyonrails.org/api_app.html) — Our backend API uses Rails 5 in its API-only configuration.
- [ActiveModelSerializers](https://github.com/rails-api/active_model_serializers) - We use AMS to serialize the JSON responses from our API.
- [Ember.js](https://github.com/emberjs/ember.js) — Our frontend is an Ember.js app that communicates with the Rails JSON API.
- [PostgreSQL](http://www.postgresql.org/) — Our primary data store.
- [Redis](http://redis.io/) — Redis for a variety of NoSQL uses.
- [Elasticsearch](https://www.elastic.co/products/elasticsearch) — Elasticsearch for searching documents.
- [Docker](https://www.docker.com) — Docker for containerized development environments.
