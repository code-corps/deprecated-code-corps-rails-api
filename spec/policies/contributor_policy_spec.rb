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

  permissions :index? do
    it 'can be viewed by logged-out users' do
      expect(subject).to permit(non_user, nil)
    end

    it 'can be viewed by logged-in users' do
      expect(subject).to permit(regular_user, nil)
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
        expect(subject).to     permit(admin_user, contributor_collaborator_user)
        expect(subject).to     permit(admin_user, contributor_admin_user)
        expect(subject).to_not permit(admin_user, contributor_owner_user)
      end
    end

    context 'when they are an admin they can' do

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
