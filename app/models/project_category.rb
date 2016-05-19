class ProjectCategory < ActiveRecord::Base
  belongs_to :project
  belongs_to :category

  validates_presence_of :project
  validates_presence_of :category
  validates_uniqueness_of :project_id, scope: :category_id
end
