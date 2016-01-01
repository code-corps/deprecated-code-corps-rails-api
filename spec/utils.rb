FB_ENABLED = "Facebook environment variables not set" unless
  ENV["FACEBOOK_APP_ID"] and
  ENV["FACEBOOK_APP_SECRET"] and
  ENV["FACEBOOK_REDIRECT_URL"]
CLOUDFRONT_ENABLED = "Cloudfront ENV variables not set" unless
  ENV["CLOUDFRONT_DOMAIN"]
S3_ENABLED = "S3 ENV variables not set" unless ENV["S3_BUCKET_NAME"]
