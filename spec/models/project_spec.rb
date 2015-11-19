require 'rails_helper'

describe Project, :type => :model do
  describe "schema" do
    it { should have_db_column(:name).of_type(:string) }
  end

  describe "relationships" do
    it { should belong_to(:owner) }
  end

  describe "ownership" do
    it "can have a user as an owner" do
      user = create(:user)
      project = create(:project, owner: user)
      expect(project).to be_persisted
      expect(project).to be_valid
      expect(project.owner).to be_a User
      expect(project.owner_type).to eq "User"
    end

    it "can have an organization as an owner" do
      organization = create(:organization)
      project = create(:project, owner: organization)
      expect(project).to be_persisted
      expect(project).to be_valid
      expect(project.owner).to be_an Organization
      expect(project.owner_type).to eq "Organization"
    end
  end
end

