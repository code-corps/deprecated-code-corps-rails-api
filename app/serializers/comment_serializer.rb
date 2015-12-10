class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :markdown, :state, :edited_at

  belongs_to :post
  belongs_to :user
end
