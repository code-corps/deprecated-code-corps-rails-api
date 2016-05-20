class ProjectCategory < ActiveRecord::Base
  belongs_to :project, required: true
  belongs_to :category, required: true

  validates :project_id, uniqueness: { scope: :category_id }
end
