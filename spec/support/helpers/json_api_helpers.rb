require "json"
require "hashie/mash"

module JsonApiHelpers
  JSON_API_HEADERS = {
    "CONTENT_TYPE" => "application/vnd.api+json; charset=utf-8"
  }.freeze

  # NOTE - GET and DELETE do not have a JSON api payload, so they
  # do not need a content type set
  # All others need to have the correct CONTENT_TYPE headers added
  # regardless of authentication, so we override the base request
  # helpers.

  def post(*args)
    super(*wrap_for_json_api(*args))
  end

  def update(*args)
    super(*wrap_for_json_api(*args))
  end

  def patch(*args)
    super(*wrap_for_json_api(*args))
  end

  def put(*args)
    super(*wrap_for_json_api(*args))
  end

  private

    def wrap_for_json_api(path, params = {}, headers = {})
      # NOTE: without a params.to_json, the middleware encodes params
      # as form, which causes errors

      params ||= {}
      headers ||= {}

      [path, params.to_json, JSON_API_HEADERS.merge(headers)]
    end
end
