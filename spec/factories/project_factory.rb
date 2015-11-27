FactoryGirl.define do

  factory :project do
    sequence(:title) { |n| "Project #{n}" }

    trait :with_s3_icon do
      after(:build) do |project, evaluator|
        project.icon_file_name = 'project.jpg'
        project.icon_content_type = 'image/jpeg'
        project.icon_file_size = 1024
        project.icon_updated_at = Time.now
      end
    end
  end

end
