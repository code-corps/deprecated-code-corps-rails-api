require "rails_helper"

describe ProjectPolicy do
  subject { described_class }

  let(:admin_user) { build_stubbed(:user) }
  let(:contributor_user) { build_stubbed(:user) }
  let(:organization) { create(:organization) }
  let(:owner_user) { build_stubbed(:user) }
  let(:pending_user) { build_stubbed(:user) }
  let(:project) { build_stubbed(:project, organization: organization) }
  let(:site_admin) { build_stubbed(:user, admin: true) }
  let(:unaffiliated_organization) { create(:organization) }
  let(:unaffiliated_project) { build_stubbed(:project, organization: unaffiliated_organization) }
  let(:unaffiliated_user) { build_stubbed(:user) }

  before do
    create(:organization_membership,
           organization: organization,
           member: pending_user,
           role: "pending")

    create(:organization_membership,
           organization: organization,
           member: contributor_user,
           role: "contributor")

    create(:organization_membership,
           organization: organization,
           member: admin_user,
           role: "admin")

    create(:organization_membership,
           organization: organization,
           member: owner_user,
           role: "owner")
  end

  permissions :index?, :show? do
    context "as a logged out user" do
      it "can view all projects" do
        expect(subject).to permit(nil, project)
        expect(subject).to permit(nil, unaffiliated_project)
      end
    end

    context "as an unaffiliated user" do
      it "can view all projects" do
        expect(subject).to permit(unaffiliated_user, project)
        expect(subject).to permit(unaffiliated_user, unaffiliated_project)
      end
    end

    context "as a pending user" do
      it "can view all projects" do
        expect(subject).to permit(pending_user, project)
        expect(subject).to permit(pending_user, unaffiliated_project)
      end
    end

    context "as a contributor user" do
      it "can view all projects" do
        expect(subject).to permit(contributor_user, project)
        expect(subject).to permit(contributor_user, unaffiliated_project)
      end
    end

    context "as an admin user" do
      it "can view all projects" do
        expect(subject).to permit(admin_user, project)
        expect(subject).to permit(admin_user, unaffiliated_project)
      end
    end

    context "as an owner user" do
      it "can view all projects" do
        expect(subject).to permit(owner_user, project)
        expect(subject).to permit(owner_user, unaffiliated_project)
      end
    end

    context "as a site admin" do
      it "can view all projects" do
        expect(subject).to permit(site_admin, project)
        expect(subject).to permit(site_admin, unaffiliated_project)
      end
    end
  end

  permissions :create?, :update? do
    context "as a logged out user" do
      it "is not permitted to create/update projects" do
        expect(subject).to_not permit(nil, create(:project))
      end
    end

    context "as an unaffiliated user" do
      it "is not permitted to create/update projects in other organizations" do
        expect(subject).to_not permit(unaffiliated_user, unaffiliated_project)
      end

      it "is not permitted to create/update projects in their organization" do
        expect(subject).to_not permit(unaffiliated_user, project)
      end
    end

    context "as a pending user" do
      it "is not permitted to create/update projects in other organizations" do
        expect(subject).to_not permit(pending_user, unaffiliated_project)
      end

      it "is not permitted to create/update projects in their organization" do
        expect(subject).to_not permit(pending_user, project)
      end
    end

    context "as a contributor user" do
      it "is not permitted to create/update projects in other organizations" do
        expect(subject).to_not permit(contributor_user, unaffiliated_project)
      end

      it "is not permitted to create/update projects in their organization" do
        expect(subject).to_not permit(contributor_user, project)
      end
    end

    context "as an admin user" do
      it "is not permitted to create/update projects in other organizations" do
        expect(subject).to_not permit(admin_user, unaffiliated_project)
      end

      it "is permitted to create/update projects in their organization" do
        expect(subject).to permit(admin_user, project)
      end
    end

    context "as an owner user" do
      it "is not permitted to create/update projects in other organizations" do
        expect(subject).to_not permit(owner_user, unaffiliated_project)
      end

      it "is permitted to create/update projects in their organization" do
        expect(subject).to permit(owner_user, project)
      end
    end

    context "as a site admin" do
      it "is permitted to create projects in other organizations" do
        expect(subject).to permit(site_admin, unaffiliated_project)
      end

      it "is permitted to create projects in their organization" do
        expect(subject).to permit(site_admin, project)
      end
    end
  end
end
