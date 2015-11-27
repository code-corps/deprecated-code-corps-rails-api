# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

Rails.application.configure do |config|

  # Paperclip Defaults
  config.paperclip_defaults = {
    storage: :s3,
    s3_protocol: :https,
    s3_credentials: {
      bucket: ENV['S3_BUCKET_NAME'],
      s3_region: 'us-east-1',
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    },
    s3_host_alias: ENV['CLOUDFRONT_DOMAIN'],
    url: ':s3_alias_url'
  }
end