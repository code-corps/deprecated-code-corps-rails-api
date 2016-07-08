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

class ProjectRole < ApplicationRecord
  belongs_to :project
  belongs_to :role

  validates :project_id, uniqueness: { scope: :role_id }
  validates :project, presence: true
  validates :role, presence: true
end
