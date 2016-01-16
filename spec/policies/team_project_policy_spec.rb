require 'rails_helper'

describe TeamProjectPolicy do

  subject { described_class }


  before do
    @project = create(:project)

    @team1 = create(:team)
    @team2 = create(:team)

    @regular_user = create(:user)

    # Pending contributor
    @pending_user = create(:user)
    create(:contributor,
           user: @pending_user,
           project: @project,
           status: "pending")

    # Collaborator
    @collaborator_user = create(:user)
    create(:contributor,
           user: @collaborator_user,
           project: @project,
           status: "collaborator")

    # Owner
    @owner_user = create(:user)
    create(:contributor,
           user: @owner_user,
           project: @project,
           status: "admin")

    # Admin
    @admin_user = create(:user)
    create(:contributor,
           user: @admin_user,
           project: @project,
           status: "owner")

    @admin_team_project = create(:team_project, 
                                 role: "admin", 
                                 project_id: @project.id, 
                                 team_id: @team1.id)
    @regular_team_project = create(:team_project, 
                                   role: "regular", 
                                   project_id: @project.id, 
                                   team_id: @team2.id)

  end

  permissions :update?, :create? do 
    context "as an anonymous user" do 
      it "it is not permitted to add or edit a team project" do
        expect(subject).to_not permit(nil, @admin_team_project)
        expect(subject).to_not permit(nil, @regular_team_project)
      end
    end

    context "as a regular user" do 
      it "it is not permitted to add or edit a team project" do
        expect(subject).to_not permit(@regular_user, @admin_team_project)
        expect(subject).to_not permit(@regular_user, @regular_team_project)
      end
    end

    context "as a pending user" do 
      it "it is not permitted to add or edit a team project" do
        expect(subject).to_not permit(@pending_user, @admin_team_project)
        expect(subject).to_not permit(@pending_user, @regular_team_project)
      end
    end

    context "as a collaborator user" do 
      it "it is not permitted to add or edit a team project" do
        expect(subject).to_not permit(@collaborator_user, @admin_team_project)
        expect(subject).to_not permit(@collaborator_user, @regular_team_project)
      end
    end

    context "as an admin user" do 
      it "it is permitted to add or edit a team project" do
        expect(subject).to permit(@admin_user, @admin_team_project)
        expect(subject).to permit(@admin_user, @regular_team_project)
      end
    end

    context "as an owner user" do 
      it "it is permitted to add or edit a team project" do
        expect(subject).to permit(@owner_user, @admin_team_project)
        expect(subject).to permit(@owner_user, @regular_team_project)
      end
    end
  end
  permissions :show? do 
    context "as an anonymous user" do 
      it "it is permitted to view any team project" do
        expect(subject).to permit(nil, @admin_team_project)
        expect(subject).to permit(nil, @regular_team_project)
      end
    end

    context "as a regular user" do 
      it "it is permitted to view any team project" do
        expect(subject).to permit(@regular_user, @admin_team_project)
        expect(subject).to permit(@regular_user, @regular_team_project)
      end
    end

    context "as a pending user" do 
      it "it is permitted to view any team project" do
        expect(subject).to permit(@pending_user, @admin_team_project)
        expect(subject).to permit(@pending_user, @regular_team_project)
      end
    end

    context "as a collaborator user" do 
      it "it is permitted to view any team project" do
        expect(subject).to permit(@collaborator_user, @admin_team_project)
        expect(subject).to permit(@collaborator_user, @regular_team_project)
      end
    end

    context "as an admin user" do 
      it "it is permitted to view any team project" do
        expect(subject).to permit(@admin_user, @admin_team_project)
        expect(subject).to permit(@admin_user, @regular_team_project)
      end
    end

    context "as an owner user" do 
      it "it is permitted to view any team project" do
        expect(subject).to permit(@owner_user, @admin_team_project)
        expect(subject).to permit(@owner_user, @regular_team_project)
      end
    end
  end

end