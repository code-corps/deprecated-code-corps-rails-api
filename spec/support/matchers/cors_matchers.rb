RSpec::Matchers.define :have_proper_cors_headers do
  match do |response|
    return response.headers["Access-Control-Allow-Origin"] == "*"
  end
end


RSpec::Matchers.define :have_proper_preflight_options_response_headers do
  match do |response|
    return false unless response.headers["Access-Control-Allow-Origin"] == "*"
    return false unless response.headers["Access-Control-Allow-Methods"] == methods
    return false unless response.headers["Access-Control-Allow-Headers"] == "test"
    return false unless response.headers.has_key? "Access-Control-Max-Age"
    return true
  end

  chain :supporting_methods do |*methods|
    @method_string = Array.wrap(methods).map(&:to_s).join(", ").upcase
  end

  def methods
    @method_string || "GET, POST, PATCH, OPTIONS"
  end
end
