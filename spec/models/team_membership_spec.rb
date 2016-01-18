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

require 'rails_helper'

describe TeamMembership, :type => :model do
  describe "schema" do
    it { should have_db_index([:member_id, :team_id]).unique }
  end

  describe "relationships" do
    it { should belong_to(:member).class_name("User") }
    it { should belong_to(:team) }
  end

  describe "validations" do
    it { should validate_uniqueness_of(:member_id).scoped_to(:team_id) }
  end
end
