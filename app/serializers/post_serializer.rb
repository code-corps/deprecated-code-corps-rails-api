class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :status, :post_type, :likes_count

  has_many :comments
  belongs_to :user
  belongs_to :project
end
