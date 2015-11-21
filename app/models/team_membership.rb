class TeamMembership < ActiveRecord::Base
  belongs_to :team
  belongs_to :member, class_name: "User"

  validates_uniqueness_of :member_id, scope: :team_id
end
