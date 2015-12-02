RSpec::Matchers.define :serialize_object do |object|
  match do |json|
    serializer =  @serializer_klass.new(object)
    serialization = ActiveModel::Serializer::Adapter.create(serializer) unless includes_specified?
    serialization = ActiveModel::Serializer::Adapter.create(serializer, include: @includes) if includes_specified?
    JSON.parse(serialization.to_json) == json
  end

  chain :with do |serializer_klass|
    @serializer_klass = serializer_klass
  end

  chain :with_includes do |includes|
    @includes = Array.wrap(includes)
  end

  def includes_specified?
    @includes.present?
  end
end
