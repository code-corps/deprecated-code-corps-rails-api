class PostSerializerWithoutIncludes < ActiveModel::Serializer
  attributes :id, :title, :body, :status, :post_type, :likes_count
end
