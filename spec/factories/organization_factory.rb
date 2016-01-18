# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  slug       :string           not null
#

FactoryGirl.define do

  factory :organization do
    sequence(:name) { |n| "Organization#{n}" }
  end

end
