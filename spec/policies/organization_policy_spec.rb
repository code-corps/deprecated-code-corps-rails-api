require "rails_helper"

describe OrganizationPolicy do

  subject { described_class }

  before do
    @organization = create(:organization)
    @unaffiliated_organization = create(:organization)

    @unaffiliated_user = create(:user)

    # Pending organization member
    @pending_user = create(:user)
    create(:organization_membership,
           organization: @organization,
           member: @pending_user,
           role: "pending")

    # Contributor organization member
    @contributor_user = create(:user)
    create(:organization_membership,
           organization: @organization,
           member: @contributor_user,
           role: "contributor")

    # Admin organization member
    @admin_user = create(:user)
    create(:organization_membership,
           organization: @organization,
           member: @admin_user,
           role: "admin")

    # Owner organization member
    @owner_user = create(:user)
    create(:organization_membership,
           organization: @organization,
           member: @owner_user,
           role: "owner")

    @site_admin = create(:user, admin: true)
  end

  permissions :show? do
    context "as a logged out user" do
      it "can view all organizations" do
        expect(subject).to permit(nil, @organization)
        expect(subject).to permit(nil, @unaffiliated_organization)
      end
    end

    context "as an unaffiliated user" do
      it "can view all organizations" do
        expect(subject).to permit(@unaffiliated_user, @organization)
        expect(subject).to permit(@unaffiliated_user, @unaffiliated_organization)
      end
    end

    context "as a pending user" do
      it "can view all organizations" do
        expect(subject).to permit(@pending_user, @organization)
        expect(subject).to permit(@pending_user, @unaffiliated_organization)
      end
    end

    context "as a contributor user" do
      it "can view all organizations" do
        expect(subject).to permit(@contributor_user, @organization)
        expect(subject).to permit(@contributor_user, @unaffiliated_organization)
      end
    end

    context "as an admin user" do
      it "can view all organizations" do
        expect(subject).to permit(@admin_user, @organization)
        expect(subject).to permit(@admin_user, @unaffiliated_organization)
      end
    end

    context "as an owner user" do
      it "can view all organizations" do
        expect(subject).to permit(@owner_user, @organization)
        expect(subject).to permit(@owner_user, @unaffiliated_organization)
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
        expect(subject).to_not permit(@unaffiliated_user, @unaffiliated_organization)
      end

      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(@unaffiliated_user, @organization)
      end
    end

    context "as a pending user" do
      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(@pending_user, @unaffiliated_organization)
      end

      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(@pending_user, @organization)
      end
    end

    context "as a contributor user" do
      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(@contributor_user, @unaffiliated_organization)
      end

      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(@contributor_user, @organization)
      end
    end

    context "as an admin user" do
      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(@admin_user, @unaffiliated_organization)
      end
    end

    context "as an owner user" do
      it "is not permitted to create/update organizations" do
        expect(subject).to_not permit(@owner_user, @unaffiliated_organization)
      end
    end
  end

  permissions :update? do
    context "as an admin user" do
      it "is permitted to update organizations" do
        expect(subject).to permit(@admin_user, @organization)
      end
    end

    context "as an owner user" do
      it "is permitted to update organizations" do
        expect(subject).to permit(@owner_user, @organization)
      end
    end

    context "as a site admin" do
      it "is not permitted to update organizations" do
        expect(subject).to_not permit(@site_admin, @organization)
      end
    end
  end

  permissions :create? do
    context "as an admin user" do
      it "is not permitted to create organizations" do
        expect(subject).to_not permit(@admin_user, @organization)
      end
    end

    context "as an owner user" do
      it "is not permitted to create organizations" do
        expect(subject).to_not permit(@owner_user, @organization)
      end
    end

    context "as a site admin" do
      it "is permitted to create organizations" do
        expect(subject).to permit(@site_admin, @organization)
      end
    end
  end
end
