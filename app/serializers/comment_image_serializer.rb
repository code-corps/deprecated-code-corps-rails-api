class CommentImageSerializer < ActiveModel::Serializer
  attributes :id, :filename

  belongs_to :user
  belongs_to :comment
end
