RSpec::Matchers.define :serialize_object do |object|
  match do |json|
    serialization = ActiveModel::Serializer::Adapter.create(@serializer, include: includes)
    JSON.parse(serialization.to_json) == json
  end

  chain :with do |serializer_klass|
    @serializer = serializer_klass.new(object)
  end

  chain :with_includes do |includes|
    @includes = Array.wrap(includes)
  end

  chain :with_scope do |scope|
    @serializer.scope = scope
  end

  def includes
    @includes ||= []
  end
end

RSpec::Matchers.define :serialize_collection do |collection|
  match do |actual_json|
    options = {}
    options = options.merge pagination_options_for collection if is_paginated? collection

    actual_json = cleanup actual_json

    serializer =  ActiveModel::Serializer::CollectionSerializer.new collection, serializer: @serializer_klass
    serialization = ActiveModel::Serializer::Adapter.create(serializer, include: includes, meta: meta)

    expected_json = cleanup JSON.parse(serialization.to_json options)

    content_is_ok = arrays_have_same_elements(expected_json["data"], actual_json["data"])
    content_is_ok and remainder_is_ok(expected_json, actual_json)
  end

  chain :with do |serializer_klass|
    @serializer_klass = serializer_klass
  end

  chain :with_includes do |includes|
    @includes = Array.wrap(includes)
  end

  chain :with_meta do |meta|
    @meta = meta
  end

  chain :with_links_to do |host|
    @host = host
  end

  def includes
    @includes ||= []
  end

  def meta
    @meta
  end

  def host
    @host || ""
  end

  def validate_meta?
    @meta.present?
  end

  def validate_links?
    @host.present?
  end

  def cleanup json
    json = json.with_indifferent_access
    json = json.except(:meta) unless validate_meta?
    json = json.except(:links) unless validate_links?
    json
  end

  def is_paginated? collection
    collection.respond_to?(:current_page) &&
    collection.respond_to?(:total_pages) &&
    collection.respond_to?(:size)
  end

  def pagination_options_for collection
    request = double(original_url: host, query_parameters: {})

    serialization_context = ActiveModelSerializers::SerializationContext.new(request)

    { serialization_context: serialization_context }
  end

  def arrays_have_same_elements a, b
    a.to_set == b.to_set
  end

  def remainder_is_ok expected_json, actual_json
    expected_json.delete(:data)
    actual_json.delete(:data)
    expected_json == actual_json
  end

end
