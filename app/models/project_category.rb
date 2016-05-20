class ProjectCategory < ActiveRecord::Base
  belongs_to :project, required: true
  belongs_to :category, required: true

  validates_uniqueness_of :project_id, scope: :category_id
end
