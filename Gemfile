source 'https://rubygems.org'
ruby '2.2.3'

gem 'rails', '4.2.5.1'

gem 'rails-api'

gem 'spring', :group => :development

gem 'pg'

gem 'active_model_serializers', github: 'rails-api/active_model_serializers'

gem 'rack-cors', require: 'rack/cors'

gem 'clearance'

gem 'doorkeeper'

gem 'pundit'

# paperclip master currently doesn't work with new version of AWS SDK
gem 'paperclip', :git=> 'https://github.com/thoughtbot/paperclip', :ref => '523bd46c768226893f23889079a7aa9c73b57d68'
gem 'aws-sdk'

gem 'sidekiq'

gem 'kaminari'

gem 'koala'

gem 'github-markdown'

gem 'html-pipeline'

gem 'obscenity'

gem 'sequenced'

gem 'aasm'

gem 'faraday'

gem 'pusher'

group :development, :test do
  gem 'annotate'

  gem 'bullet'

  gem 'dotenv-rails'

  gem 'fakeredis', :require => "fakeredis/rspec"

  gem 'pry-rails'
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-stack_explorer'

  gem 'rspec-rails', '~> 3.0'
end

group :development do
  gem 'foreman'
  gem 'seed-fu'
  gem 'sinatra', :require => nil # for Sidekiq UI to work in development
end

group :test do
  gem 'capybara'
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'hashie'
  gem 'oauth2'
  gem 'pusher-fake'
  gem 'rspec-sidekiq'
  gem 'shoulda-matchers', '3.0.1' # locked due to https://github.com/thoughtbot/shoulda-matchers/issues/880
  gem 'vcr'
  gem 'webmock'
end
