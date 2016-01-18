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

FactoryGirl.define do

  factory :post_image do
    association :user
    association :post

    trait :with_s3_image do
      after(:build) do |post_image, evaluator|
        post_image.image_file_name = "post_image.jpg"
        post_image.image_content_type = "image/jpeg"
        post_image.image_file_size = 1024
        post_image.image_updated_at = Time.now
      end
    end

  end

end
