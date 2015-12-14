require 'rails_helper'

describe ProjectPolicy do

  subject { described_class }


  before do
    @project = create(:project)

    @regular_user = create(:user)
    @pending_user = create(:user)
    @collaborator_user = create(:user)
    @admin_user = create(:user)
    @owner_user = create(:user)

    @admin = create(:user, admin: true)

    @pending_contributor = create(:contributor, user: @pending_user, project: @project)
    @collaborator_contributor = create(:contributor, user: @collaborator_user, project: @project)
    @admin_contributor = create(:contributor, user: @admin_user, project: @project)
    @owner_contributor = create(:contributor, user: @owner_user, project: @project)
  end

  permissions :index?, :show? do

    context "as an unaffiliated user" do
      it "can view all projects" do
        expect(subject).to permit(nil, @project)
      end
    end

    context "as a regular user" do
      it "can view all projects" do
        expect(subject).to permit(@regular_user, @project)
      end
    end

    context "as a pending user" do
      it "can view all projects" do
        expect(subject).to permit(@pending_user, @project)
      end
    end

    context "as a collaborator user" do
      it "can view all projects" do
        expect(subject).to permit(@collaborator_user, @project)
      end
    end

    context "as an admin user" do
      it "can view all projects" do
        expect(subject).to permit(@admin_user, @project)
      end
    end

    context "as an owner user" do
      it "can view all projects" do
        expect(subject).to permit(@owner_user, @project)
      end
    end
  end

  permissions :create?, :update? do

    context "as an unaffiliated user" do
      it "is not permitted to create/update projects for others" do
        expect(subject).to_not permit(nil, create(:project, owner: @regular_user))
      end
    end

    context "as a regular user" do
      it "is not permitted to create/update projects for others" do
        expect(subject).to_not permit(@regular_user, create(:project, owner: create(:user)))
      end

      it "is permitted to create/update projects for themselves" do
        expect(subject).to permit(@regular_user, create(:project, owner: @regular_user))
      end
    end

    context "as a pending user" do
      it "is not permitted to create/update projects for others" do
        expect(subject).to_not permit(@pending_user, create(:project, owner: @regular_user))
      end

      it "is permitted to create/update projects for themselves" do
        expect(subject).to permit(@pending_user, create(:project, owner: @pending_user))
      end
    end

    context "as a collaborator user" do
      it "is not permitted to create/update projects for others" do
        expect(subject).to_not permit(@collaborator_user, create(:project, owner: @regular_user))
      end

      it "is permitted to create/update projects for themselves" do
        expect(subject).to permit(@collaborator_user, create(:project, owner: @collaborator_user))
      end
    end

    context "as an admin user" do
      it "is not permitted to create/update projects for others" do
        expect(subject).to_not permit(@admin_user, create(:project, owner: @regular_user))
      end

      it "is permitted to create/update projects for themselves" do
        expect(subject).to permit(@admin_user, create(:project, owner: @admin_user))
      end
    end

    context "as an owner user" do
      it "is not permitted to create/update projects for others" do
        expect(subject).to_not permit(@owner_user, create(:project, owner: @regular_user))
      end

      it "is permitted to create/update projects for themselves" do
        expect(subject).to permit(@owner_user, create(:project, owner: @owner_user))
      end
    end
  end

  permissions :create? do #for differing admin rights to cut down on # of tests
    context "as an site admin" do
      it "is permitted to create projects for others" do
        expect(subject).to permit(@admin, create(:project, owner: @regular_user))
      end

      it "is permitted to create projects for themselves" do
        expect(subject).to permit(@admin, create(:project, owner: @admin))
      end
    end
  end

  permissions :update? do #for differing admin rights to cut down on # of tests
    context "as an site admin" do
      it "is not permitted to update projects for others" do
        expect(subject).to_not permit(@admin, create(:project, owner: @regular_user))
      end

      it "is permitted to update projects for themselves" do
        expect(subject).to permit(@admin, create(:project, owner: @admin))
      end
    end
  end
end