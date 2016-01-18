# == Schema Information
#
# Table name: team_memberships
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  member_id  :integer
#  team_id    :integer
#

class TeamMembership < ActiveRecord::Base
  belongs_to :team
  belongs_to :member, class_name: "User"

  validates_uniqueness_of :member_id, scope: :team_id
end
