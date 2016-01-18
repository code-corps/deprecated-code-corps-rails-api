# == Schema Information
#
# Table name: post_likes
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PostLikeSerializer < ActiveModel::Serializer
  belongs_to :user
  belongs_to :post, serializer: PostSerializerWithoutIncludes
end
