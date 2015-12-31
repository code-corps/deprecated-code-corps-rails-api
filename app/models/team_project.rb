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

  # Least permissive is 0
  ROLES_MAP = {
    "regular" => 0,
    "admin" => 1
  }

  def role_value
    ROLES_MAP[self.role]
  end
end
