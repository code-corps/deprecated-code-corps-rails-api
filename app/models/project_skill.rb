class ProjectSkill < ActiveRecord::Base
  belongs_to :project, required: true
  belongs_to :skill, required: true

  validates :project_id, uniqueness: { scope: :skill_id }
end
