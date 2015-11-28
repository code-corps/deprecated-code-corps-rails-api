source 'https://rubygems.org'
ruby '2.2.3'

gem 'rails', '4.2.5'

gem 'rails-api'

gem 'spring', :group => :development

gem 'pg'

gem 'active_model_serializers', github: 'rails-api/active_model_serializers'

gem 'clearance'

gem 'doorkeeper'

gem 'cancancan', '~> 1.10'

gem 'paperclip'

gem 'aws-sdk'

gem 'sidekiq'

group :development, :test do
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
  gem 'factory_girl_rails', '~> 4.0'
  gem 'shoulda-matchers'

  gem 'oauth2'

  gem 'hashie'
end
