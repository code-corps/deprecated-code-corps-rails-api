# == Schema Information
#
# Table name: post_images
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  post_id            :integer          not null
#  filename           :text             not null
#  base64_photo_data  :text             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#

class PostImageSerializer < ActiveModel::Serializer
  attributes :id, :filename

  belongs_to :user
  belongs_to :post
end
