require_relative "boot"

require "rails/all"
require "obscenity/active_model"
require "csv"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CodeCorpsApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Required for adding oauth applications in Doorkeeper
    config.middleware.use ActionDispatch::Flash

    # Turn off CSRF since we're using an API only
    config.action_controller.allow_forgery_protection = false

    cors_origins = ENV.fetch("CORS_ORIGINS", "*")
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins cors_origins
        resource "*", headers: :any, methods: [:get, :post, :patch, :options, :delete]
      end
    end
  end
end
