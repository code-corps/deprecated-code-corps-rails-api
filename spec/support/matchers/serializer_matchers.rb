RSpec::Matchers.define :serialize_object do |object|
  match do |json|
    serializer =  @serializer_klass.new(object)
    serialization = ActiveModel::Serializer::Adapter.create(serializer)
    JSON.parse(serialization.to_json) == json
  end

  chain :with do |serializer_klass|
    @serializer_klass = serializer_klass
  end
end
