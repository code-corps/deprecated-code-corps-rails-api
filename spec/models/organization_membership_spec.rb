require 'rails_helper'

describe OrganizationMembership, :type => :model do
  describe "schema" do
    it { should have_db_index([:member_id, :organization_id]).unique }
  end

  describe "relationships" do
    it { should belong_to(:member).class_name("User") }
    it { should belong_to(:organization) }
  end

  describe "validations" do
    it { should validate_uniqueness_of(:member_id).scoped_to(:organization_id) }
  end

  it "should have a working 'role' enum" do
    membership = create(:organization_membership)

    expect(membership.admin?).to be false
    expect(membership.regular?).to be true

    membership.admin!
    expect(membership.admin?).to be true
    expect(membership.regular?).to be false

    membership.regular!
    expect(membership.admin?).to be false
    expect(membership.regular?).to be true
  end
end
