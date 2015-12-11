class PostImageSerializer < ActiveModel::Serializer
  attributes :id, :filename

  belongs_to :user
  belongs_to :post
end
