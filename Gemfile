source 'https://rubygems.org'
ruby '2.2.3'

gem 'rails', '4.2.5'

gem 'rails-api'

gem 'spring', :group => :development

gem 'pg'

gem 'active_model_serializers', github: 'rails-api/active_model_serializers'

gem 'rack-cors', require: 'rack/cors'

gem 'clearance'

gem 'doorkeeper'

gem 'pundit'

gem 'paperclip'

gem 'aws-sdk'

gem 'sidekiq'

gem 'kaminari'

gem 'koala'

gem 'github-markdown'

gem 'html-pipeline'

gem 'obscenity'

gem 'sequenced'

gem 'aasm'

group :development, :test do
  gem 'bullet'

  gem 'dotenv-rails'

  gem 'pry-rails'
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-stack_explorer'

  gem 'rspec-rails', '~> 3.0'
  gem 'rspec-sidekiq'
  gem 'fakeredis', :require => "fakeredis/rspec"
end

group :development do
  gem 'seed-fu'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'hashie'
  gem 'oauth2'
  gem 'shoulda-matchers'
  gem 'vcr'
  gem 'webmock'
end
