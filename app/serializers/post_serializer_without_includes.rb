class PostSerializerWithoutIncludes < ActiveModel::Serializer
  attributes :id, :number, :post_type, :state, :status,
             :title, :body, :markdown, :likes_count, :comments_count,
             :edited_at

  def likes_count
    object.post_likes_count
  end
end
