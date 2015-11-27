class UserSkill < ActiveRecord::Base
  belongs_to :user
  belongs_to :skill

  validates_presence_of :user
  validates_presence_of :skill
  validates_uniqueness_of :user_id, scope: :skill_id
end
