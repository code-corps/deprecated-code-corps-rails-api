require "rails_helper"

describe ProjectSkillPolicy do
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

    @project_skill = create(:project_skill, project: @project)

    @unaffiliated_project_skill = create(:project_skill, project: @unaffiliated_project)

    @site_admin = create(:user, admin: true)
  end

  permissions :create?, :destroy? do
    context "as a logged out user" do
      it "is not permitted" do
        expect(subject).to_not permit(nil, create(:project))
      end
    end

    context "as an unaffiliated user" do
      it "is not permitted in other organizations" do
        expect(subject).to_not permit(@unaffiliated_user, @unaffiliated_project_skill)
      end

      it "is not permitted in their organization" do
        expect(subject).to_not permit(@unaffiliated_user, @project_skill)
      end
    end

    context "as a pending user" do
      it "is not permitted in other organizations" do
        expect(subject).to_not permit(@pending_user, @unaffiliated_project_skill)
      end

      it "is not permitted in their organization" do
        expect(subject).to_not permit(@pending_user, @project_skill)
      end
    end

    context "as a contributor user" do
      it "is not permitted in other organizations" do
        expect(subject).to_not permit(@contributor_user, @unaffiliated_project_skill)
      end

      it "is not permitted in their organization" do
        expect(subject).to_not permit(@contributor_user, @project_skill)
      end
    end

    context "as an admin user" do
      it "is not permitted in other organizations" do
        expect(subject).to_not permit(@admin_user, @unaffiliated_project_skill)
      end

      it "is permitted in their organization" do
        expect(subject).to permit(@admin_user, @project_skill)
      end
    end

    context "as an owner user" do
      it "is not permitted in other organizations" do
        expect(subject).to_not permit(@owner_user, @unaffiliated_project_skill)
      end

      it "is permitted in their organization" do
        expect(subject).to permit(@owner_user, @project_skill)
      end
    end

    context "as a site admin" do
      it "is permitted in other organizations" do
        expect(subject).to permit(@site_admin, @unaffiliated_project_skill)
      end

      it "is permitted in their organization" do
        expect(subject).to permit(@site_admin, @project_skill)
      end
    end
  end
end
