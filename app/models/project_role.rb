# == Schema Information
#
# Table name: project_roles
#
#  id         :integer          not null, primary key
#  project_id :integer
#  role_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProjectRole < ActiveRecord::Base
  belongs_to :project, required: true
  belongs_to :role, required: true

  validates :project_id, uniqueness: { scope: :role_id }
end
