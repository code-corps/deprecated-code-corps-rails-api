class UserSkill < ActiveRecord::Base
  belongs_to :user
  belongs_to :skill

  validates_presence_of :user
  validates_presence_of :skill
end
