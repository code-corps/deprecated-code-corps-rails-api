require "rails_helper"

describe GithubRepositoryPolicy do
  subject { described_class }

  let(:admin) { build_stubbed(:user) }
  let(:contributor) { build_stubbed(:user) }
  let(:github_repository) { build_stubbed(:github_repository, project: project) }
  let(:organization) { build_stubbed(:organization) }
  let(:owner) { build_stubbed(:user) }
  let(:pending_user) { build_stubbed(:user) }
  let(:project) { build_stubbed(:project, organization: organization) }
  let(:unassociated_user) { build_stubbed(:user) }

  before do
    create(
      :organization_membership,
      member: pending_user,
      organization: organization,
      role: :pending
    )

    create(
      :organization_membership,
      member: contributor,
      organization: organization,
      role: :contributor
    )

    create(
      :organization_membership,
      member: admin,
      organization: organization,
      role: :admin
    )

    create(
      :organization_membership,
      member: owner,
      organization: organization,
      role: :owner
    )
  end

  permissions :create? do
    it "is not permitted for unauthenticated users" do
      expect(subject).not_to permit(nil, github_repository)
    end

    it "is not permitted for users not associated with the organization" do
      expect(subject).not_to permit(unassociated_user, github_repository)
    end

    it "is not permitted for users pending for organization membership" do
      expect(subject).not_to permit(pending_user, github_repository)
    end

    it "is not permitted for organization contributors" do
      expect(subject).not_to permit(contributor, github_repository)
    end

    it "is permitted for organization admins" do
      expect(subject).to permit(admin, github_repository)
    end

    it "is permitted for organization onwers" do
      expect(subject).to permit(owner, github_repository)
    end
  end
end
