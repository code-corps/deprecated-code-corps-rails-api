class Team < ActiveRecord::Base
  has_many :team_memberships
  has_many :members, through: :team_memberships
  belongs_to :organization
end
