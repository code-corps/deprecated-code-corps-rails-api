class ProjectRole < ActiveRecord::Base
  belongs_to :project, required: true
  belongs_to :role, required: true

  validates :project_id, uniqueness: { scope: :role_id }
end
