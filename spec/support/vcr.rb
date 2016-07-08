VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join("spec", "vcr")
  c.hook_into :webmock
  c.configure_rspec_metadata!

  # Uncomment for debugging VCR
  # c.debug_logger = File.open("log/test.log", "w")

  c.allow_http_connections_when_no_cassette = false

  c.default_cassette_options = { :serialize_with => :psych }

  c.ignore_hosts "elasticsearch"

  ignore_localhost = true
end
