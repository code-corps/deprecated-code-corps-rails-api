class RoleSkill < ActiveRecord::Base
  belongs_to :role
  belongs_to :skill

  validates_presence_of :role
  validates_presence_of :skill
  validates_uniqueness_of :role_id, scope: :skill_id
end
