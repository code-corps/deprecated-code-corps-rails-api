# == Schema Information
#
# Table name: import_skill_failures
#
#  id         :integer          not null, primary key
#  import_id  :integer          not null
#  skill_id   :integer
#  data       :json             not null
#  issues     :text             not null, is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :import_skill_failure do
    association :skill
    association :import

    sequence(:issues) do |n|
      [
        "First issue for import_skill_failure #{n}",
        "Second issue for import_skill_failure #{n}"
      ]
    end

    sequence(:data) do |n|
      {
        "Status" => "Categorize",
        "Batch" => "A",
        "Original Row" => "1",
        "Original Order" => "1",
        "Skill" => "Skill #{n}",
        "Cat 1" => "Backend Developer",
        "Cat 2" => "Architect",
        "Cat 3" => nil,
        "Cat 4" => nil,
        "Cat 5" => nil,
        "Cat 6" => nil
      }
    end
  end
end
