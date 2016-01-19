# == Schema Information
#
# Table name: skill_categories
#
#  id         :integer          not null, primary key
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do

  factory :skill_category do
    sequence(:title) { |n| "Category #{n}" }
  end

end
