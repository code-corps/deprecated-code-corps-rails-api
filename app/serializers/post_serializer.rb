class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :status, :post_type

  has_many :comments
  belongs_to :user
  belongs_to :project
end
