# == Schema Information
#
# Table name: role_skills
#
#  id         :integer          not null, primary key
#  role_id    :integer
#  skill_id   :integer
#  cat        :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class RoleSkill < ActiveRecord::Base
  belongs_to :role
  belongs_to :skill

  validates_presence_of :role
  validates_presence_of :skill
  validates_uniqueness_of :role_id, scope: :skill_id

  enum cat: [:cat1, :cat2, :cat3, :cat4, :cat5, :cat6]
end
