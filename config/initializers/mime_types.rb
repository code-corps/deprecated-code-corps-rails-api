mime_type = Mime::Type.lookup("application/vnd.api+json")
ActionDispatch::ParamsParser::DEFAULT_PARSERS[mime_type] = lambda do |body|
  JSON.parse(body)
end
