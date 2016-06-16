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
    before do
      create(:organization_membership, organization: create(:organization))
    end

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

  describe "analytics tracking" do
    context "when creating" do
      it "tracks creating pending memberships" do
        expect_any_instance_of(Analytics).
          to receive(:track_requested_organization_membership)
        create(:organization_membership, role: "pending")
      end

      it "tracks creating contributors" do
        expect_any_instance_of(Analytics).
          to receive(:track_created_organization_membership)
        create(:organization_membership, role: "contributor")
      end

      it "tracks creating admins" do
        expect_any_instance_of(Analytics).
          to receive(:track_created_organization_membership)
        create(:organization_membership, role: "admin")
      end

      it "tracks creating owners" do
        expect_any_instance_of(Analytics).
          to receive(:track_created_organization_membership)
        create(:organization_membership, role: "owner")
      end
    end

    context "when approving" do
      it "tracks" do
        membership = create(:organization_membership, role: "pending")
        expect_any_instance_of(Analytics).
          to receive(:track_approved_organization_membership)
        membership.contributor!
      end
    end

    context "when rejecting" do
      it "tracks" do
        membership = create(:organization_membership, role: "pending")
        expect_any_instance_of(Analytics).
          to receive(:track_rejected_organization_membership)
        membership.destroy
      end
    end

    context "when removing" do
      it "tracks" do
        membership = create(:organization_membership, role: "contributor")
        expect_any_instance_of(Analytics).
          to receive(:track_removed_organization_membership)
        membership.destroy
      end
    end
  end
end
