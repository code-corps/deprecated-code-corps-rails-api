class TeamProject < ActiveRecord::Base
  belongs_to :team
  belongs_to :project

  validates :team, presence: true
  validates :project, presence: true

  validates_uniqueness_of :project_id, scope: :team_id

  enum role: {
    regular: "regular",
    admin: "admin"
  }
end
