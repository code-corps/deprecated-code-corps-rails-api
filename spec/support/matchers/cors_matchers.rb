RSpec::Matchers.define :have_proper_cors_headers do
  match do |response|
    return response.headers['Access-Control-Allow-Origin'] == '*'
  end
end

RSpec::Matchers.define :have_proper_preflight_options_response_headers do
  match do |response|
    headers = response.headers
    return false unless headers['Access-Control-Allow-Origin'] == '*'
    return false unless headers['Access-Control-Allow-Methods'] == methods
    return false unless headers['Access-Control-Allow-Headers'] == 'test'
    return false unless headers.key? 'Access-Control-Max-Age'
    return true
  end

  def methods
    @method_string || 'GET, POST, PATCH, OPTIONS'
  end
end
