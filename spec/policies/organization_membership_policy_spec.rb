require "rails_helper"

describe OrganizationMembershipPolicy do
  subject { described_class }

  let(:test_organization) { create(:organization) }

  let(:non_member) { create(:user) }
  let(:pending_user) { create(:user) }
  let(:contributor) { create(:user) }
  let(:admin) { create(:user) }
  let(:owner) { create(:user) }

  def new_membership_for(member: create(:user), role: "pending", organization: test_organization)
    build(:organization_membership, member: member, organization: organization, role: role)
  end

  def create_membership_for(member: create(:user), role: "pending", organization: test_organization)
    create(:organization_membership, member: member, organization: organization, role: role)
  end

  before do
    create_membership_for(member: pending_user, role: "pending")
    create_membership_for(member: contributor, role: "contributor")
    create_membership_for(member: admin, role: "admin")
    create_membership_for(member: owner, role: "owner")
  end

  permissions :index?, :organization_index?, :show? do
    it "is allowed for everyone" do
      [nil, non_member, pending_user, contributor, admin, owner].each do |user|
        expect(subject).to permit(user, OrganizationMembership)
      end
    end
  end

  permissions :create? do
    context "when the user is anonymous" do
      it "is not allowed" do
        expect(subject).not_to permit(nil, OrganizationMembership)
      end
    end

    context "when the user is creating their own role" do
      context "when the user is a non-member" do
        it "is allowed for pending role" do
          membership = new_membership_for(member: non_member, role: "pending")
          expect(subject).to permit(non_member, membership)
        end

        it "is not allowed for any other role" do
          %w(contributor admin owner).each do |role|
            membership = new_membership_for(member: non_member, role: role)
            expect(subject).not_to permit(non_member, membership)
          end
        end
      end

      context "when the user is already a member" do
        it "is not allowed for any combination of a user or membership role" do
          [pending_user, contributor, admin, owner].each do |user|
            %w(pending contributor admin owner).each do |role|
              membership = new_membership_for(member: user, role: role)
              expect(subject).not_to permit(user, membership)
            end
          end
        end
      end
    end

    context "when the user is trying to create another user's role" do
      it "is not allowed for any combination of a user or membership role" do
        [pending_user, contributor, admin, owner].each do |user|
          %w(pending contributor admin owner).each do |role|
            membership = new_membership_for(role: role)
            expect(subject).not_to permit(user, membership)
          end
        end
      end
    end
  end

  permissions :update? do
    context "when the user is a anonymous, non_member, pending or contributor" do
      it "is not allowed for any combination of old and new membership role" do
        [nil, non_member, pending_user, contributor].each do |user|
          %w(pending contributor admin owner).each do |old_role|
            membership = create_membership_for(role: old_role)
            %w(pending contributor admin owner).each do |new_role|
              membership.role = new_role
              expect(subject).not_to permit(user, membership)
            end
          end
        end
      end
    end

    context "when the user is admin" do
      it "is allowed when promoting pending to contributor" do
        membership = create_membership_for(role: "pending")
        membership.role = "contributor"
        expect(subject).to permit(admin, membership)
      end

      it "is allowed when promoting pending to admin" do
        membership = create_membership_for(role: "pending")
        membership.role = "admin"
        expect(subject).to permit(admin, membership)
      end

      it "is allowed when promoting contributor to admin" do
        membership = create_membership_for(role: "contributor")
        membership.role = "admin"
        expect(subject).to permit(admin, membership)
      end

      it "is not allowed when promoting any role to owner" do
        %w(pending contributor admin).each do |role|
          membership = create_membership_for(role: role)
          membership.role = "owner"
          expect(subject).not_to permit(admin, membership)
        end
      end

      it "is not allowed when demoting to any role from owner" do
        membership = create_membership_for(role: "owner")
        %w(pending contributor admin).each do |new_role|
          membership.role = new_role
          expect(subject).not_to permit(admin, membership)
        end
      end
    end

    context "when the user is owner" do
      it "is allowed when promoting or demoting any combination of roles not including owner" do
        %w(pending contributor admin).each do |old_role|
          membership = create_membership_for(role: old_role)
          %w(pending contributor admin).each do |new_role|
            membership.role = new_role
            expect(subject).to permit(owner, membership)
          end
        end
      end

      it "is allowed when promoting any role to owner" do
        %w(pending contributor admin).each do |old_role|
          membership = create_membership_for(role: old_role)
          membership.role = "owner"
          expect(subject).to permit(owner, membership)
        end
      end

      it "is not allowed when demoting owner to any role" do
        membership = create_membership_for(role: "owner")
        %w(pending contributor admin).each do |new_role|
          membership.role = new_role
          expect(subject).not_to permit(owner, membership)
        end
      end
    end
  end

  permissions :destroy? do
    context "when the user is anonymous" do
      it "is not allowed for any role" do
        %w(pending contributor admin owner).each do |role|
          membership = create_membership_for(role: role)
          expect(subject).not_to permit(nil, membership)
        end
      end
    end

    context "when the user is destroying their own role" do
      it "is not allowed for owners" do
        expect(subject).not_to permit(owner, owner.organization_memberships.first)
      end

      it "is allowed for any other user" do
        [pending_user, contributor, admin].each do |user|
          expect(subject).to permit(user, user.organization_memberships.first)
        end
      end
    end

    context "when the user is destroying another user's role" do
      it "is not allowed for pending or contributor users" do
        [pending_user, contributor].each do |user|
          %w(pending contributor admin owner).each do |role|
            membership = create_membership_for(role: role)
            expect(subject).not_to permit(user, membership)
          end
        end
      end

      context "when the user is admin or owner" do
        it "is allowed for pending, contributor and admin memberships" do
          [admin, owner].each do |user|
            %w(pending contributor admin).each do |role|
              membership = create_membership_for(role: role)
              expect(subject).to permit(user, membership)
            end
          end
        end

        it "is not allowed for owner memberships" do
          [admin, owner].each do |user|
            membership = create_membership_for(role: "owner")
            expect(subject).not_to permit(user, membership)
          end
        end
      end
    end
  end
end
