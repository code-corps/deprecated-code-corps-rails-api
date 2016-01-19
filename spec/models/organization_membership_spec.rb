# == Schema Information
#
# Table name: organization_memberships
#
#  id              :integer          not null, primary key
#  role            :string           default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  member_id       :integer
#  organization_id :integer
#

require "rails_helper"

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

    expect(membership.pending?).to be true
    expect(membership.owner?).to be false
    expect(membership.admin?).to be false
    expect(membership.contributor?).to be false

    membership.contributor!
    expect(membership.owner?).to be false
    expect(membership.admin?).to be false
    expect(membership.contributor?).to be true

    membership.admin!
    expect(membership.owner?).to be false
    expect(membership.admin?).to be true
    expect(membership.contributor?).to be false

    membership.owner!
    expect(membership.owner?).to be true
    expect(membership.admin?).to be false
    expect(membership.contributor?).to be false
  end
end
