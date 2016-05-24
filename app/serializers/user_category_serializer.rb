class UserCategorySerializer < ActiveModel::Serializer
  belongs_to :user
  belongs_to :category
end
