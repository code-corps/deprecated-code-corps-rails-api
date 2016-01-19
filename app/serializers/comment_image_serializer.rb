# == Schema Information
#
# Table name: comment_images
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  comment_id         :integer          not null
#  filename           :text             not null
#  base64_photo_data  :text             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#

class CommentImageSerializer < ActiveModel::Serializer
  attributes :id, :filename

  belongs_to :user
  belongs_to :comment
end
