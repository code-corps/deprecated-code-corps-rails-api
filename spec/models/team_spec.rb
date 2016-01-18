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

require 'rails_helper'

describe Team, :type => :model do
  describe "schema" do
    it { should have_db_column(:name).of_type(:string) }
  end

  describe "relationships" do
    it { should have_many(:members).through(:team_memberships) }
    it { should have_many(:projects).through(:team_projects) }
    it { should belong_to(:organization) }
  end
end

