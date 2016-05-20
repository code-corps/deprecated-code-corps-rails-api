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

class ProjectSkill < ActiveRecord::Base
  belongs_to :project, required: true
  belongs_to :skill, required: true

  validates :project_id, uniqueness: { scope: :skill_id }
end
