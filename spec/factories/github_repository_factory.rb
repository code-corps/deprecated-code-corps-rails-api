# == Schema Information
#
# Table name: github_repositories
#
#  id              :integer          not null, primary key
#  repository_name :string           not null
#  owner_name      :string           not null
#  project_id      :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do

  factory :github_repository do
    sequence(:owner_name) { |n| "owner#{n}" }
    sequence(:repository_name) { |n| "repository#{n}" }

    association :project
  end

end
