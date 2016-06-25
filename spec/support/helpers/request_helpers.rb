require "json"
require "hashie/mash"

module RequestHelpers
  def json
    Hashie::Mash.new JSON.parse(last_response.body)
  end

  # Host redirects locally to allow testing API subdomain
  def host
    "http://api.lvh.me:3000"
  end

  def authenticated_get(path, args, token)
    get full_path(path), args, authorization_header(token)
  end

  def authenticated_post(path, args, token)
    post full_path(path), args, authorization_header(token)
  end

  def authenticated_put(path, args, token)
    put full_path(path), args, authorization_header(token)
  end

  def authenticated_patch(path, args, token)
    patch full_path(path), args, authorization_header(token)
  end

  def authenticated_delete(path, args, token)
    delete full_path(path), args, authorization_header(token)
  end

  def json_api_params_for(type, hash)
    data = {}
    data[:id] = hash[:id] if hash[:id].present?
    data[:type] = type
    data[:attributes] = hash.except(:id)

    { data: data }
  end

  def cors_options(path, method)
    options(full_path(path), nil, options_header(method))
  end

  private

    def authorization_header(token)
      { "HTTP_AUTHORIZATION" => "Bearer #{token}" }
    end

    def full_path(path)
      "#{host}/#{path}"
    end

    def options_header(method)
      {
        "HTTP_ORIGIN" => "*",
        "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => method.to_s.upcase,
        "HTTP_ACCESS_CONTROL_REQUEST_HEADERS" => "test"
      }
    end
end
