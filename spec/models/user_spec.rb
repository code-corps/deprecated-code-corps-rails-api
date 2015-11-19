require 'rails_helper'

describe User, :type => :model do

  let(:user) { User.create(email: "joshdotsmith@gmail.com", username: "joshsmith", password: "password") }

  it "is not an admin by default" do
    expect(user.admin?).to eq false
  end

  it "knows when it is an admin" do
    user.admin = true
    user.save
    expect(user.admin?).to eq true
  end

  describe "schema" do
    it { should have_db_column(:username).of_type(:string) }
  end

  describe "relationships" do
    it { should have_many(:organization_memberships).with_foreign_key("member_id") }
    it { should have_many(:organizations).through(:organization_memberships) }
    it { should have_many(:team_memberships).with_foreign_key("member_id") }
    it { should have_many(:teams).through(:team_memberships) }
    it { should have_many(:projects) }
  end

end
