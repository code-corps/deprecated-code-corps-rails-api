source "https://rubygems.org"
ruby "2.2.3"

gem "rails", "5.0.0"

gem "active_model_serializers", "0.10.1"

gem "puma"

gem "spring", group: :development

gem "pg"

gem "aasm"
gem "analytics-ruby", require: "segment"
gem "aws-sdk"
gem "clearance"
gem "counter_culture"
gem "doorkeeper"
gem "faraday"
gem "full-name-splitter"
gem "github-markdown"
gem "html-pipeline"
gem "html-pipeline-rouge_filter"
gem "kaminari"
gem "koala"
gem "newrelic_rpm"
gem "obscenity"
# paperclip master currently doesn"t work with new version of AWS SDK
gem "paperclip", git: "https://github.com/thoughtbot/paperclip", ref: "523bd46c768226893f23889079a7aa9c73b57d68"
gem "pundit"
gem "pusher"
gem "rack-cors", require: "rack/cors"
gem "searchkick"
gem "seed-fu"
gem "sentry-raven"
gem "sequenced"
gem "sidekiq"
gem "strip_attributes"

group :production do
  gem "rails_12factor"
end

group :development, :test do
  gem "annotate"
  gem "bullet"
  gem "dotenv-rails"
  gem "fakeredis", require: "fakeredis/rspec"
  gem "pry-rails"
  gem "pry"
  gem "pry-nav"
  gem "pry-remote"
  gem "pry-stack_explorer"
  gem "rspec-rails", "~> 3.0"
end

group :development do
  gem "foreman"
  gem "sinatra", github: "sinatra", require: nil # for Sidekiq UI to work in development
end

group :test do
  gem "capybara"
  gem "codeclimate-test-reporter", require: nil
  gem "database_cleaner"
  gem "factory_girl_rails", "~> 4.0"
  gem "hashie"
  gem "oauth2"
  gem "pusher-fake"
  gem "rspec-sidekiq"
  gem "shoulda-matchers", "3.0.1" # locked due to https://github.com/thoughtbot/shoulda-matchers/issues/880
  gem "vcr"
  gem "webmock"
end
