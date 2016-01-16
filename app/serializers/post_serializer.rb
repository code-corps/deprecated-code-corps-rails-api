class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :status, :post_type, :likes_count, :markdown,
    :number, :state, :edited_at

  has_many :comments
  has_many :post_user_mentions
  has_many :comment_user_mentions

  belongs_to :user
  belongs_to :project
end
