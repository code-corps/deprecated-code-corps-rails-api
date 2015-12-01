class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :markdown

  belongs_to :post
  belongs_to :user
end
