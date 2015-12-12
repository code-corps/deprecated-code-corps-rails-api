FactoryGirl.define do

  factory :comment_image do
    association :user
    association :comment
  end

  trait :comment_with_s3_image do
    after(:build) do |comment_image, evaluator|
      comment_image.image_file_name = 'comment_image.jpg'
      comment_image.image_content_type = 'image/jpeg'
      comment_image.image_file_size = 1024
      comment_image.image_updated_at = Time.now
    end
  end

end
