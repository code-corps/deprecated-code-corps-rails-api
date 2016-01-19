# == Schema Information
#
# Table name: skill_categories
#
#  id         :integer          not null, primary key
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SkillCategory < ActiveRecord::Base
  has_many :skills
end
