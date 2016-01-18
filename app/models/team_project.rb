# == Schema Information
#
# Table name: team_projects
#
#  id         :integer          not null, primary key
#  team_id    :integer          not null
#  project_id :integer          not null
#  role       :string           default("regular"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TeamProject < ActiveRecord::Base
  belongs_to :team
  belongs_to :project

  validates :team, presence: true
  validates :project, presence: true

  validates :project_id, uniqueness: { scope: :team_id }

  enum role: {
    regular: "regular",
    admin: "admin"
  }
end
