require 'rails_helper'

describe ContributorPolicy do

  subject { described_class }

    let(:non_user)                              { nil }
    let(:regular_user)                          { create(:user) }
    let(:collaborator_user)                     { create(:user) }
    let(:admin_user)                            { create(:user) }
    let(:owner_user)                            { create(:user) }
    let(:admin)                                 { create(:user, admin: true) }
    let(:project)                               { create(:project) }
    let(:contributor_regular_user)              { create(:contributor, status: "pending", user: create(:user), project: project) }
    let(:contributor_collaborator_user)         { create(:contributor, status: "collaborator", user: create(:user), project: project) }
    let(:contributor_admin_user)                { create(:contributor, status: "admin", user: create(:user), project: project) }
    let(:contributor_owner_user)                { create(:contributor, status: "owner", user: create(:user), project: project) }

    let(:contributor_regular_user_as_self)      { create(:contributor, status: "pending", user: regular_user, project: project) }
    let(:contributor_collaborator_user_as_self) { create(:contributor, status: "collaborator", user: collaborator_user, project: project) }
    let(:contributor_admin_user_as_self)        { create(:contributor, status: "admin", user: admin_user, project: project) }
    let(:contributor_owner_user_as_self)        { create(:contributor, status: "owner", user: owner_user, project: project) }

  before do
    @project = create(:project)

    @pending_user = create(:user)
    create(:contributor, user: @pending_user, project: @project, status: "pending")

    @collaborator_user = create(:user)
    create(:contributor, user: @collaborator_user, project: @project, status: "collaborator")

    @admin_user = create(:user)
    create(:contributor, user: @admin_user, project: @project, status: "admin")

    @owner_user = create(:user)
    create(:contributor, user: @owner_user, project: @project, status: "owner")

    @contributor_pending = create(:contributor, project: @project, status: "pending")
    @contributor_collaborator = create(:contributor, project: @project, status: "collaborator")
    @contributor_admin = create(:contributor, project: @project, status: "admin")
    @contributor_owner = create(:contributor, project: @project, status: "owner")
  end

  permissions :index? do

    context "when an anonymous user (not logged in) is performing the action" do
      it "is allowed"  do
        expect(subject).to permit(nil, nil)
      end
    end

    context "when 'pending' user is performing the action" do
      it "is allowed"  do
        expect(subject).to permit(@pending_user, nil)
      end
    end

    context "when 'collaborator' user is performing the action" do
      it "is allowed"  do
        expect(subject).to permit(@collaborator_user, nil)
      end
    end

    context "when 'admin' user is performing the action" do
      it "is allowed"  do
        expect(subject).to permit(@admin_userm, nil)
      end
    end

    context "when 'owner' user is performing the action" do
      it "is allowed"  do
        expect(subject).to permit(@owner_user, nil)
      end
    end
  end

  permissions :create? do
    context 'when they are a non-user they can' do
      it 'not change any contributors'  do
        expect(subject).to_not permit(nil, contributor_regular_user)
        expect(subject).to_not permit(nil, contributor_collaborator_user)
        expect(subject).to_not permit(nil, contributor_admin_user)
        expect(subject).to_not permit(nil, contributor_owner_user)
      end
    end

    context 'when they are a regular user they can' do
      it 'change only themselves to pending' do
        expect(subject).to     permit(regular_user, contributor_regular_user_as_self)
        expect(subject).to_not permit(regular_user, contributor_collaborator_user)
        expect(subject).to_not permit(regular_user, contributor_admin_user)
        expect(subject).to_not permit(regular_user, contributor_owner_user)
      end
    end

    context 'when they are a contributor user they can' do
      it 'change only themselves' do
        expect(subject).to_not permit(collaborator_user, contributor_collaborator_user)
        expect(subject).to_not permit(collaborator_user, contributor_admin_user)
        expect(subject).to_not permit(collaborator_user, contributor_owner_user)
      end
    end

    context 'when they are an admin user they can' do
      it 'change admin and collaborator users' do
        expect(subject).to     permit(admin_user, contributor_collaborator_user)
        expect(subject).to     permit(admin_user, contributor_admin_user)
        expect(subject).to_not permit(admin_user, contributor_owner_user)
      end
    end

    context 'when they are an owner user they can' do
      it 'change every type of user' do
        expect(subject).to     permit(owner_user, contributor_collaborator_user)
        expect(subject).to     permit(owner_user, contributor_admin_user)
        expect(subject).to_not permit(owner_user, contributor_owner_user)
      end
    end

    context 'when they are an admin they can' do

    end
  end

  permissions :update? do
    context "when an anonymous user (not logged in) is performing the action" do
      context "and they are changing a 'pending' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_pending.status = "collaborator"
          expect(subject).not_to permit(nil, @contributor_pending)
          @contributor_pending.status = "admin"
          expect(subject).not_to permit(nil, @contributor_pending)
          @contributor_pending.status = "owner"
          expect(subject).not_to permit(nil, @contributor_pending)
        end
      end

      context "and they are changing a 'collaborator' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_collaborator.status = "pending"
          expect(subject).not_to permit(nil, @contributor_collaborator)
          @contributor_collaborator.status = "admin"
          expect(subject).not_to permit(nil, @contributor_collaborator)
          @contributor_collaborator.status = "owner"
          expect(subject).not_to permit(nil, @contributor_collaborator)
        end
      end

      context "and they are changing an 'admin' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_admin.status = "pending"
          expect(subject).not_to permit(nil, @contributor_admin)
          @contributor_admin.status = "collaborator"
          expect(subject).not_to permit(nil, @contributor_admin)
          @contributor_admin.status = "owner"
          expect(subject).not_to permit(nil, @contributor_admin)
        end
      end

      context "and they are changing an 'admin' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_owner.status = "pending"
          expect(subject).not_to permit(nil, @contributor_owner)
          @contributor_owner.status = "collaborator"
          expect(subject).not_to permit(nil, @contributor_owner)
          @contributor_owner.status = "admin"
          expect(subject).not_to permit(nil, @contributor_owner)
        end
      end
    end

    context "when a 'pending' is performing the action" do
      context "and they are changing a 'pending' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_pending.status = "collaborator"
          expect(subject).not_to permit(@pending_user, @contributor_pending)
          @contributor_pending.status = "admin"
          expect(subject).not_to permit(@pending_user, @contributor_pending)
          @contributor_pending.status = "owner"
          expect(subject).not_to permit(@pending_user, @contributor_pending)
        end
      end

      context "and they are changing a 'collaborator' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_collaborator.status = "pending"
          expect(subject).not_to permit(@pending_user, @contributor_collaborator)
          @contributor_collaborator.status = "admin"
          expect(subject).not_to permit(@pending_user, @contributor_collaborator)
          @contributor_collaborator.status = "owner"
          expect(subject).not_to permit(@pending_user, @contributor_collaborator)
        end
      end

      context "and they are changing an 'admin' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_admin.status = "pending"
          expect(subject).not_to permit(@pending_user, @contributor_admin)
          @contributor_admin.status = "collaborator"
          expect(subject).not_to permit(@pending_user, @contributor_admin)
          @contributor_admin.status = "owner"
          expect(subject).not_to permit(@pending_user, @contributor_admin)
        end
      end

      context "and they are changing an 'admin' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_owner.status = "pending"
          expect(subject).not_to permit(@pending_user, @contributor_owner)
          @contributor_owner.status = "collaborator"
          expect(subject).not_to permit(@pending_user, @contributor_owner)
          @contributor_owner.status = "admin"
          expect(subject).not_to permit(@pending_user, @contributor_owner)
        end
      end
    end

    context "when a 'collaborator' is performing the action" do
      context "and they are changing a 'pending' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_pending.status = "collaborator"
          expect(subject).not_to permit(@collaborator_user, @contributor_pending)
          @contributor_pending.status = "admin"
          expect(subject).not_to permit(@collaborator_user, @contributor_pending)
          @contributor_pending.status = "owner"
          expect(subject).not_to permit(@collaborator_user, @contributor_pending)
        end
      end

      context "and they are changing a 'collaborator' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_collaborator.status = "pending"
          expect(subject).not_to permit(@collaborator_user, @contributor_collaborator)
          @contributor_collaborator.status = "admin"
          expect(subject).not_to permit(@collaborator_user, @contributor_collaborator)
          @contributor_collaborator.status = "owner"
          expect(subject).not_to permit(@collaborator_user, @contributor_collaborator)
        end
      end

      context "and they are changing an 'admin' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_admin.status = "pending"
          expect(subject).not_to permit(@collaborator_user, @contributor_admin)
          @contributor_admin.status = "collaborator"
          expect(subject).not_to permit(@collaborator_user, @contributor_admin)
          @contributor_admin.status = "owner"
          expect(subject).not_to permit(@collaborator_user, @contributor_admin)
        end
      end

      context "and they are changing an 'admin' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_owner.status = "pending"
          expect(subject).not_to permit(@collaborator_user, @contributor_owner)
          @contributor_owner.status = "collaborator"
          expect(subject).not_to permit(@collaborator_user, @contributor_owner)
          @contributor_owner.status = "admin"
          expect(subject).not_to permit(@collaborator_user, @contributor_owner)
        end
      end
    end

    context "when an 'admin' is performing the action" do
      context "and they are changing a 'pending' contributor" do
        it "is not allowed for changing changing to 'admin' or 'owner'"  do
          @contributor_pending.status = "admin"
          expect(subject).not_to permit(@admin_user, @contributor_pending)
          @contributor_pending.status = "owner"
          expect(subject).not_to permit(@admin_user, @contributor_pending)
        end

        it "is allowed for changing to 'collaborator'" do
          @contributor_pending.status = "collaborator"
          expect(subject).to permit(@admin_user, @contributor_pending)
        end
      end

      context "and they are changing a 'collaborator' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_collaborator.status = "pending"
          expect(subject).not_to permit(@admin_user, @contributor_collaborator)
          @contributor_collaborator.status = "admin"
          expect(subject).not_to permit(@admin_user, @contributor_collaborator)
          @contributor_collaborator.status = "owner"
          expect(subject).not_to permit(@admin_user, @contributor_collaborator)
        end
      end

      context "and they are changing an 'admin' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_admin.status = "pending"
          expect(subject).not_to permit(@admin_user, @contributor_admin)
          @contributor_admin.status = "collaborator"
          expect(subject).not_to permit(@admin_user, @contributor_admin)
          @contributor_admin.status = "owner"
          expect(subject).not_to permit(@admin_user, @contributor_admin)
        end
      end

      context "and they are changing an 'owner' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_owner.status = "pending"
          expect(subject).not_to permit(@admin_user, @contributor_owner)
          @contributor_owner.status = "collaborator"
          expect(subject).not_to permit(@admin_user, @contributor_owner)
          @contributor_owner.status = "admin"
          expect(subject).not_to permit(@admin_user, @contributor_owner)
        end
      end
    end

    context "when an 'owner' is performing the action" do
      context "and they are changing a 'pending' contributor" do
        it "is not allowed for changing to 'admin' or 'owner'"  do
          @contributor_pending.status = "admin"
          expect(subject).not_to permit(@owner_user, @contributor_pending)
          @contributor_pending.status = "owner"
          expect(subject).not_to permit(@owner_user, @contributor_pending)
        end

        it "is allowed for changing to 'collaborator'" do
          @contributor_pending.status = "collaborator"
          expect(subject).to permit(@owner_user, @contributor_pending)
        end
      end

      context "and they are changing a 'collaborator' contributor" do
        it "is not allowed for changing to 'pending' or 'owner'"  do
          @contributor_collaborator.status = "pending"
          expect(subject).not_to permit(@owner_user, @contributor_collaborator)
          @contributor_collaborator.status = "owner"
          expect(subject).not_to permit(@owner_user, @contributor_collaborator)
        end

        it "is allowed for changing to 'admin'" do
          @contributor_collaborator.status = "admin"
          expect(subject).to permit(@owner_user, @contributor_collaborator)
        end
      end

      context "and they are changing an 'admin' contributor" do
        it "is not allowed for changing to 'pending' or 'owner'"  do
          @contributor_admin.status = "pending"
          expect(subject).not_to permit(@owner_user, @contributor_admin)
          @contributor_admin.status = "owner"
          expect(subject).not_to permit(@owner_user, @contributor_admin)
        end

        it "is allowed for changing to 'collaborator'" do
          @contributor_admin.status = "collaborator"
          expect(subject).to permit(@owner_user, @contributor_admin)
        end
      end

      context "and they are changing an 'admin' contributor" do
        it "is not allowed for any type of change"  do
          @contributor_owner.status = "pending"
          expect(subject).not_to permit(@owner_user, @contributor_owner)
          @contributor_owner.status = "collaborator"
          expect(subject).not_to permit(@owner_user, @contributor_owner)
          @contributor_owner.status = "admin"
          expect(subject).not_to permit(@owner_user, @contributor_owner)
        end
      end
    end
  end

  permissions :delete? do
    context "when an anonymous user (not logged in) is performing the action" do
      it "is not not allowed on any type of contributor"  do
        expect(subject).to_not permit(nil, @contributor_pending)
        expect(subject).to_not permit(nil, @contributor_collaborator)
        expect(subject).to_not permit(nil, @contributor_admin)
        expect(subject).to_not permit(nil, contributor_owner_user)
      end
    end

    context "when a 'pending' user is performing the action" do
      it "is not not allowed on any type of contributor"  do
        expect(subject).to_not permit(@pending_user, @contributor_pending)
        expect(subject).to_not permit(@pending_user, @contributor_collaborator)
        expect(subject).to_not permit(@pending_user, @contributor_admin)
        expect(subject).to_not permit(@pending_user, contributor_owner_user)
      end
    end

    context "when a 'collaborator' user is performing the action" do
      it "is not not allowed on any type of contributor"  do
        expect(subject).to_not permit(@collaborator_user, @contributor_pending)
        expect(subject).to_not permit(@collaborator_user, @contributor_collaborator)
        expect(subject).to_not permit(@collaborator_user, @contributor_admin)
        expect(subject).to_not permit(@collaborator_user, contributor_owner_user)
      end
    end

    context "when an 'admin' user is performing the action" do
      it "is allowed on 'pending' and 'collaborator' records" do
        expect(subject).to permit(@admin_user, @contributor_pending)
        expect(subject).to permit(@admin_user, @contributor_collaborator)
      end

      it "is not allowed on 'admin' and 'owner' records" do
        expect(subject).to_not permit(@admin_user, @contributor_admin)
        expect(subject).to_not permit(@admin_user, contributor_owner_user)
      end
    end

    context "when an 'owner' user is performing the action" do
      it "is allowed on 'pending', 'collaborator' and 'admin' records" do
        expect(subject).to permit(@owner_user, @contributor_pending)
        expect(subject).to permit(@owner_user, @contributor_collaborator)
        expect(subject).to permit(@owner_user, @contributor_admin)
      end

      it "is not allowed on 'owner' records" do
        expect(subject).to_not permit(@user, @contributor_owner)
      end
    end
  end
end



# non_user
# - can view collaborators
# - can not add themselves to pending on any project
# - can not change the status of any other user

# regular_user
# - can view collaborators
# - can add themselves to pending on any project
# - can remove themselves from their position
# - can not change the status of any other user

# collaborator_user
# - can view collaborators
# - can remove themselves from their position
# - can not change the status of any other user

# admin_user
# - can view collaborators
# - can change a user from pending to collaborator
# - can change a user from collaborator to admin
# - can remove themselves from their position
# - can not make themselves admin

# owner_user
# - can view collaborators
# - can change a user from pending to collaborator
# - can change a user from collaborator to admin
# - can not remove themselves from their position
