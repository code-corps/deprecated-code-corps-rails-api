require 'rails_helper'

describe Team, :type => :model do
  describe "schema" do
    it { should have_db_column(:name).of_type(:string) }
  end

  describe "relationships" do
    it { should have_many(:members).through(:team_memberships) }
    it { should belong_to(:organization) }
  end
end

