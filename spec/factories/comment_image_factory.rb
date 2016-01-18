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

FactoryGirl.define do

  factory :comment_image do
    association :user
    association :comment

    trait :with_s3_image do
      after(:build) do |comment_image, evaluator|
        comment_image.image_file_name = 'comment_image.jpg'
        comment_image.image_content_type = 'image/jpeg'
        comment_image.image_file_size = 1024
        comment_image.image_updated_at = Time.now
      end
    end
  end

end
