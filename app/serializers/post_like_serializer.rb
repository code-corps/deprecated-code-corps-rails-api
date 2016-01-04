class PostLikeSerializer < ActiveModel::Serializer
  belongs_to :user
  belongs_to :post, serializer: PostSerializerWithoutIncludes
end
