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
