require 'rails_helper'

describe GithubRepositoryPolicy do

  subject { described_class }

  before do
    organization = create(:organization)
    project = create(:project, organization: organization)

    @github_repository = create(:github_repository, project: project)

    @unassociated_user = create(:user)

    @pending_user = create(:user)
    create(:organization_membership, member: @pending_user, organization: organization, role: :pending)

    @contributor = create(:user)
    create(:organization_membership, member: @contributor, organization: organization, role: :contributor)

    @admin = create(:user)
    create(:organization_membership, member: @admin, organization: organization, role: :admin)

    @owner = create(:user)
    create(:organization_membership, member: @owner, organization: organization, role: :owner)
  end

  permissions :create? do
    it "is not permitted for unauthenticated users" do
      expect(subject).not_to permit(nil, @github_repository)
    end

    it "is not permitted for users not associated with the organization" do
      expect(subject).not_to permit(@unassociated_user, @github_repository)
    end
    it "is not permitted for users pending for organization membership" do
      expect(subject).not_to permit(@pending_user, @github_repository)
    end

    it "is not permitted for organization contributors" do
      expect(subject).not_to permit(@contributor, @github_repository)
    end

    it "is permitted for organization admins" do
      expect(subject).to permit(@admin, @github_repository)
    end

    it "is permitted for organization onwers" do
      expect(subject).to permit(@owner, @github_repository)
    end
  end
end
