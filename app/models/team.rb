# == Schema Information
#
# Table name: teams
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#

class Team < ActiveRecord::Base
  has_many :team_memberships
  has_many :members, through: :team_memberships
  has_many :team_projects
  has_many :projects, through: :team_projects
  belongs_to :organization
end
