require 'rails_helper'

describe ProjectPolicy do

  subject { described_class }


  before do
    @organization = create(:organization)
    @unaffiliated_organization = create(:organization)

    @project = create(:project, organization: @organization)
    @unaffiliated_project = create(:project, organization: @unaffiliated_organization)

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

  permissions :index?, :show? do

    context "as a logged out user" do
      it "can view all projects" do
        expect(subject).to permit(nil, @project)
        expect(subject).to permit(nil, @unaffiliated_project)
      end
    end

    context "as an unaffiliated user" do
      it "can view all projects" do
        expect(subject).to permit(@unaffiliated_user, @project)
        expect(subject).to permit(@unaffiliated_user, @unaffiliated_project)
      end
    end

    context "as a pending user" do
      it "can view all projects" do
        expect(subject).to permit(@pending_user, @project)
        expect(subject).to permit(@pending_user, @unaffiliated_project)
      end
    end

    context "as a contributor user" do
      it "can view all projects" do
        expect(subject).to permit(@contributor_user, @project)
        expect(subject).to permit(@contributor_user, @unaffiliated_project)
      end
    end

    context "as an admin user" do
      it "can view all projects" do
        expect(subject).to permit(@admin_user, @project)
        expect(subject).to permit(@admin_user, @unaffiliated_project)
      end
    end

    context "as an owner user" do
      it "can view all projects" do
        expect(subject).to permit(@owner_user, @project)
        expect(subject).to permit(@owner_user, @unaffiliated_project)
      end
    end

    context "as a site admin" do
      it "can view all projects" do
        expect(subject).to permit(@site_admin, @project)
        expect(subject).to permit(@site_admin, @unaffiliated_project)
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
        expect(subject).to_not permit(@unaffiliated_user, @unaffiliated_project)
      end

      it "is not permitted to create/update projects in their organization" do
        expect(subject).to_not permit(@unaffiliated_user, @project)
      end
    end

    context "as a pending user" do
      it "is not permitted to create/update projects in other organizations" do
        expect(subject).to_not permit(@pending_user, @unaffiliated_project)
      end

      it "is not permitted to create/update projects in their organization" do
        expect(subject).to_not permit(@pending_user, @project)
      end
    end

    context "as a contributor user" do
      it "is not permitted to create/update projects in other organizations" do
        expect(subject).to_not permit(@contributor_user, @unaffiliated_project)
      end

      it "is not permitted to create/update projects in their organization" do
        expect(subject).to_not permit(@contributor_user, @project)
      end
    end

    context "as an admin user" do
      it "is not permitted to create/update projects in other organizations" do
        expect(subject).to_not permit(@admin_user, @unaffiliated_project)
      end

      it "is permitted to create/update projects in their organization" do
        expect(subject).to permit(@admin_user, @project)
      end
    end

    context "as an owner user" do
      it "is not permitted to create/update projects in other organizations" do
        expect(subject).to_not permit(@owner_user, @unaffiliated_project)
      end

      it "is permitted to create/update projects in their organization" do
        expect(subject).to permit(@owner_user, @project)
      end
    end

    context "as a site admin" do
      it "is permitted to create projects in other organizations" do
        expect(subject).to permit(@site_admin, @unaffiliated_project)
      end

      it "is permitted to create projects in their organization" do
        expect(subject).to permit(@site_admin, @project)
      end
    end
  end
end