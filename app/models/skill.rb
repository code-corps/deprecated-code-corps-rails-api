class Skill < ActiveRecord::Base
  belongs_to :skill_category

  validates_presence_of :title
  validates_presence_of :skill_category
end
