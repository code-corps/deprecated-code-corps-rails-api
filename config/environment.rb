# Load the Rails application.
require_relative "application"

# Application-wide configuration
Rails.application.configure do

  config.paperclip_defaults = {
    storage: :s3,
    s3_protocol: :https,
    s3_credentials: {
      bucket: ENV["S3_BUCKET_NAME"],
      s3_region: "us-east-1",
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    },
    s3_host_alias: ENV["CLOUDFRONT_DOMAIN"],
    url: ":s3_alias_url"
  }
end

# Initialize the Rails application.
Rails.application.initialize!
