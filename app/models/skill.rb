# == Schema Information
#
# Table name: skills
#
#  id                :integer          not null, primary key
#  title             :string           not null
#  description       :string
#  skill_category_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Skill < ActiveRecord::Base
  belongs_to :skill_category

  validates_presence_of :title
  validates_presence_of :skill_category
end
