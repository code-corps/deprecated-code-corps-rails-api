# == Schema Information
#
# Table name: projects
#
#  id                :integer          not null, primary key
#  title             :string           not null
#  description       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  icon_file_name    :string
#  icon_content_type :string
#  icon_file_size    :integer
#  icon_updated_at   :datetime
#  base64_icon_data  :text
#  slug              :string           not null
#  organization_id   :integer          not null
#

FactoryGirl.define do
  factory :project do
    sequence(:title) { |n| "Project#{n}" }
    sequence(:description) { |n| "Project description #{n}" }

    association :organization

    trait :with_categories do
      after(:build) do |project|
        create(:project_category, project: project)
      end
    end

    trait :with_s3_icon do
      after(:build) do |project|
        project.icon_file_name = "project.jpg"
        project.icon_content_type = "image/jpeg"
        project.icon_file_size = 1024
        project.icon_updated_at = Time.now
      end
    end
  end
end
