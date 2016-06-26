require "rails_helper"

describe OrganizationPolicy do
  subject { described_class }

  let(:admin_user) { build_stubbed(:user) }
  let(:contributor_user) { build_stubbed(:user) }
  let(:organization) { build_stubbed(:organization) }
  let(:owner_user) { build_stubbed(:user) }
  let(:pending_user) { build_stubbed(:user) }
  let(:site_admin) { build_stubbed(:user, admin: true) }
  let(:unaffiliated_organization) { build_stubbed(:organization) }
  let(:unaffiliated_user) { build_stubbed(:user) }

  before do
    # Pending organization member
    build_stubbed(:organization_membership,
                  organization: organization,
                  member: pending_user,
                  role: "pending")

    # Contributor organization member
    build_stubbed(:organization_membership,
                  organization: organization,
                  member: contributor_user,
                  role: "contributor")

    # Admin organization member
    create(:organization_membership,
           organization: organization,
           member: admin_user,
           role: "admin")

    # Owner organization member
    create(:organization_membership,
           organization: organization,
           member: owner_user,
           role: "owner")
  end

  permissions :index? do
    it "can be viewed by anyone" do
      expect(subject).to permit(nil, Organization)
    end
  end

  permissions :show? do
    context "as a logged out user" do
      it "can view all organizations" do
        expect(subject).to permit(nil, organization)
        expect(subject).to permit(nil, unaffiliated_organization)
      end
    end

    context "as an unaffiliated user" do
      it "can view all organizations" do
        expect(subject).to permit(unaffiliated_user, organization)
        expect(subject).to permit(unaffiliated_user, unaffiliated_organization)
      end
    end

    context "as a pending user" do
      it "can view all organizations" do
        expect(subject).to permit(pending_user, organization)
        expect(subject).to permit(pending_user, unaffiliated_organization)
      end
    end

    context "as a contributor user" do
      it "can view all organizations" do
        expect(subject).to permit(contributor_user, organization)
        expect(subject).to permit(contributor_user, unaffiliated_organization)
      end
    end

    context "as an admin user" do
      it "can view all organizations" do
        expect(subject).to permit(admin_user, organization)
        expect(subject).to permit(admin_user, unaffiliated_organization)
      end
    end

    context "as an owner user" do
      it "can view all organizations" do
        expect(subject).to permit(owner_user, organization)
        expect(subject).to permit(owner_user, unaffiliated_organization)
      end
    end
  end

  permissions :create?, :update? do
    context "as a logged out user" do
      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(nil, create(:project))
      end
    end

    context "as an unaffiliated user" do
      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(unaffiliated_user, unaffiliated_organization)
      end

      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(unaffiliated_user, organization)
      end
    end

    context "as a pending user" do
      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(pending_user, unaffiliated_organization)
      end

      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(pending_user, organization)
      end
    end

    context "as a contributor user" do
      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(contributor_user, unaffiliated_organization)
      end

      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(contributor_user, organization)
      end
    end

    context "as an admin user" do
      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(admin_user, unaffiliated_organization)
      end
    end

    context "as an owner user" do
      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(owner_user, unaffiliated_organization)
      end
    end
  end

  permissions :update? do
    context "as an admin user" do
      it "is permitted to update organizations" do
        expect(subject).to permit(admin_user, organization)
      end
    end

    context "as an owner user" do
      it "is permitted to update organizations" do
        expect(subject).to permit(owner_user, organization)
      end
    end

    context "as a site admin" do
      it "is not permitted to update organizations" do
        expect(subject).to_not permit(site_admin, organization)
      end
    end
  end

  permissions :create? do
    context "as an admin user" do
      it "is not permitted to create organizations" do
        expect(subject).to_not permit(admin_user, organization)
      end
    end

    context "as an owner user" do
      it "is not permitted to create organizations" do
        expect(subject).to_not permit(owner_user, organization)
      end
    end

    context "as a site admin" do
      it "is permitted to create organizations" do
        expect(subject).to permit(site_admin, organization)
      end
    end
  end
end
