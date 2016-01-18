# == Schema Information
#
# Table name: team_projects
#
#  id         :integer          not null, primary key
#  team_id    :integer          not null
#  project_id :integer          not null
#  role       :string           default("regular"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :team_project do
    association :team
    association :project
  end
end
