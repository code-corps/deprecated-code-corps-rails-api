# == Schema Information
#
# Table name: project_skills
#
#  id         :integer          not null, primary key
#  project_id :integer
#  skill_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProjectSkill < ApplicationRecord
  belongs_to :project
  belongs_to :skill

  validates :project_id, uniqueness: { scope: :skill_id }
  validates :project, presence: true
  validates :skill, presence: true
end
