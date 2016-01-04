FactoryGirl.define do

  factory :project do
    sequence(:title) { |n| "Project#{n}" }

    association :owner, factory: :organization

    transient do
      contributors_count 5
      contributors_status "collaborator"
    end

    trait :with_s3_icon do
      after(:build) do |project, evaluator|
        project.icon_file_name = 'project.jpg'
        project.icon_content_type = 'image/jpeg'
        project.icon_file_size = 1024
        project.icon_updated_at = Time.now
      end
    end


    trait :with_contributors do

      after(:create) do |project, evaluator|
        evaluator.contributors_count.times do
          create(:contributor, status: evaluator.contributors_status, project: project)
        end
      end
    end
  end

end
