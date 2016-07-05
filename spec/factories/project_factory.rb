# == Schema Information
#
# Table name: projects
#
#  id                        :integer          not null, primary key
#  title                     :string           not null
#  description               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  icon_file_name            :string
#  icon_content_type         :string
#  icon_file_size            :integer
#  icon_updated_at           :datetime
#  base64_icon_data          :text
#  slug                      :string           not null
#  organization_id           :integer          not null
#  aasm_state                :string
#  long_description_body     :text
#  long_description_markdown :text
#  open_posts_count          :integer          default(0), not null
#  closed_posts_count        :integer          default(0), not null
#

FactoryGirl.define do
  factory :project do
    sequence(:title) { |n| "Project#{n}" }
    sequence(:description) { |n| "Project description #{n}" }
    sequence(:long_description_markdown) { |n| "Long project description #{n}" }

    association :organization

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
