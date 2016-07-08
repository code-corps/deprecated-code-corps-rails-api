FROM ruby:2.2.5

RUN gem update --system 2.6.1
RUN gem install bundler --version $BUNDLER_VERSION

RUN apt-get update -qq && apt-get install -y build-essential

# ImageMagick
RUN apt-get install -y imagemagick

# PostgreSQL
RUN apt-get install -y libpq-dev

# Node.js runtime
RUN apt-get install -y nodejs

# Set directory for our app
ENV APP_HOME /code-corps-api
RUN mkdir $APP_HOME

# Copy Gemfile and bundle
WORKDIR $APP_HOME
COPY Gemfile $APP_HOME/Gemfile
COPY Gemfile.lock $APP_HOME/Gemfile.lock
RUN bundle install

# Copy code
ADD . $APP_HOME
