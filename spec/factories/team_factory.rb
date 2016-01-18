# == Schema Information
#
# Table name: teams
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#

FactoryGirl.define do

  factory :team do
    sequence(:name) { |n| "Team #{n}" }
  end

end
