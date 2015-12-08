class PostUserMentionSerializer < ActiveModel::Serializer
  attributes :id, :indices, :username

  belongs_to :user
  belongs_to :post, serializer: PostSerializerWithoutIncludes
end
