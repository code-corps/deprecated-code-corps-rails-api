## How do I install the Code Corps API?

### Requirements

You will need to install [Docker](https://docs.docker.com/engine/installation/).

Here are some direct links if you're on [Mac OS X](https://docs.docker.com/docker-for-mac/) or [Windows](https://docs.docker.com/docker-for-windows/).

Follow those download instructions. Once you can run the `docker` command, you can safely move on.

### Clone this repository

You'll want to [clone this repository](https://help.github.com/articles/cloning-a-repository/) with `git clone https://github.com/code-corps/code-corps-api.git`.

The directory structure will look like the following:

```shell
code-corps-api/          # → Root folder for this project
├── app/
├── bin/
├── ...                  # → More standard Rails files
├── docker-compose.yml   # → Compose file for configuring Docker containers
└── Dockerfile           # → Creates base Ruby Docker container
```

### Setup your Docker containers and run the server

> Note: We bind to ports 6380 for `redis` and 5001 for `foreman`. Make sure you're not running anything on those ports. We do not expose port 5432 for `postgres` or 9200 for `elasticsearch`.

Go to the `code-corps-api` directory and type:

```shell
docker-compose build
docker-compose up
```

Docker will set up your base Ruby container, as well as containers for:

- `postgres`
- `elasticsearch`
- `redis`
- `web` runs `foreman s` with the `Procfile.dev`
- `test` runs `guard start`

You can view more detailed information about these services in the `docker-compose.yml` file, but you shouldn't need to edit it unless you're intentionally contributing changes to our Docker workflow.

### Setup your database

You can now create and seed your database in the `web` container with our helpful bash script:

```shell
bin/setup
```

At its heart, this script is running:

```shell
docker-compose run web rake db:create db:migrate db:test:prepare db:seed_fu
```

Point your browser (or make a direct request) to `http://api.lvh.me/ping`. There should be a `{"ping":"pong"}` response from it. If you hit the index route instead, you'll probably get `INDEX NOT FOUND` since it's not serving up our Ember app yet.

`lvh.me` resolves to `localhost` so you can use subdomains, like our `api` subdomain.

### Next steps

Now that you're set up, you should [read more about how to develop with the API](USAGE.md).

### Issues installing?

Having trouble?

Create an issue in this repo and we'll look into it.

Docker's a bit new for us, so there may be some hiccups at first. But hopefully this makes for a less painful developer environment for you in the long run.
