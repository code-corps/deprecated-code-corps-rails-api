class CommentUserMentionSerializer < ActiveModel::Serializer
  attributes :id, :indices, :username

  belongs_to :user
  belongs_to :comment, serializer: CommentSerializer
end
