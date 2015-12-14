FactoryGirl.define do

  factory :post_image do
    association :user
    association :post

    trait :with_s3_image do
      after(:build) do |post_image, evaluator|
        post_image.image_file_name = 'post_image.jpg'
        post_image.image_content_type = 'image/jpeg'
        post_image.image_file_size = 1024
        post_image.image_updated_at = Time.now
      end
    end

  end

end
