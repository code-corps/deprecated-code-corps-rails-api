# == Schema Information
#
# Table name: project_categories
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  category_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ProjectCategory < ApplicationRecord
  belongs_to :project
  belongs_to :category

  validates :project_id, uniqueness: { scope: :category_id }
  validates :project, presence: true
  validates :category, presence: true
end
