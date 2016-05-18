# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string           not null
#  ability    :string           not null
#

FactoryGirl.define do

  factory :role do
    sequence(:name) { |n| "Role #{n}" }
    sequence(:ability) { |n| "Ability #{n}" }
  end

end
