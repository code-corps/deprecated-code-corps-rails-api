class Team < ActiveRecord::Base
  has_many :team_memberships
  has_many :members, through: :team_memberships
  has_many :team_projects
  has_many :projects, through: :team_projects
  belongs_to :organization
end
