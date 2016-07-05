# == Schema Information
#
# Table name: user_skills
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  skill_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserSkill < ApplicationRecord
  belongs_to :user
  belongs_to :skill

  validates_presence_of :user
  validates_presence_of :skill
  validates_uniqueness_of :user_id, scope: :skill_id
end
