require 'json'
require 'hashie/mash'

module RequestHelpers
  def json
    Hashie::Mash.new JSON.parse(last_response.body)
  end

  # Host redirects locally to allow testing API subdomain
  def host
    "http://api.lvh.me:3000"
  end

  def authenticated_get(path, args, token)
    get "#{host}/#{path}", args, {"HTTP_AUTHORIZATION" => "Bearer #{token}"}
  end

  def authenticated_post(path, args, token)
    post "#{host}/#{path}", args, {"HTTP_AUTHORIZATION" => "Bearer #{token}"}
  end

  def authenticated_put(path, args, token)
    put "#{host}/#{path}", args, {"HTTP_AUTHORIZATION" => "Bearer #{token}"}
  end

  def authenticated_patch(path, args, token)
    patch "#{host}/#{path}", args, {"HTTP_AUTHORIZATION" => "Bearer #{token}"}
  end

  def authenticated_delete(path, args, token)
    delete "#{host}/#{path}", args, {"HTTP_AUTHORIZATION" => "Bearer #{token}"}
  end
end
