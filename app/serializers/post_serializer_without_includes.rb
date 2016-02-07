class PostSerializerWithoutIncludes < ActiveModel::Serializer
  attributes :id, :title, :body, :status, :post_type, :likes_count, :number,
    :created_at, :edited_at

  belongs_to :user
end
