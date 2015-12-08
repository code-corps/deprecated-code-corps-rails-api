require 'rails_helper'

describe PostPolicy do

  subject { described_class }

  before do
    @project = create(:project)

    @regular_user = create(:user)

    @pending_user = create(:user)
    create(:contributor, user: @pending_user, project: @project, status: "pending")

    @collaborator_user = create(:user)
    create(:contributor, user: @collaborator_user, project: @project, status: "collaborator")
    
    @owner_user = create(:user)
    create(:contributor, user: @owner_user, project: @project, status: "admin")

    @admin_user = create(:user)
    create(:contributor, user: @admin_user, project: @project, status: "owner")

    @idea_post = create(:post, post_type: "idea", project: @project)
    @progress_post = create(:post, post_type: "progress", project: @project)
    @task_post = create(:post, post_type: "task", project: @project)
    @issue_post = create(:post, post_type: "issue", project: @project)
  end

  permissions :index?, :show? do
    context "as an anonymous user" do
      it "is permitted to view any post" do
        expect(subject).to permit(nil, @issue_post)
        expect(subject).to permit(nil, @idea_post)
        expect(subject).to permit(nil, @progress_post)
        expect(subject).to permit(nil, @task_post)
      end
    end

    context "as a pending user" do
      it "is permitted to view any post" do
        expect(subject).to permit(@pending_user, @issue_post)
        expect(subject).to permit(@pending_user, @idea_post)
        expect(subject).to permit(@pending_user, @progress_post)
        expect(subject).to permit(@pending_user, @task_post)
      end
    end

    context "as a regular user" do
      it "is permitted to view any post" do
        expect(subject).to permit(@regular_user, @issue_post)
        expect(subject).to permit(@regular_user, @idea_post)
        expect(subject).to permit(@regular_user, @progress_post)
        expect(subject).to permit(@regular_user, @task_post)
      end
    end

    context "as a collaborator user" do
      it "is permitted to view any post" do
        expect(subject).to permit(@collaborator_user, @issue_post)
        expect(subject).to permit(@collaborator_user, @idea_post)
        expect(subject).to permit(@collaborator_user, @progress_post)
        expect(subject).to permit(@collaborator_user, @task_post)
      end
    end

    context "as an admin user" do
      it "is permitted to view any post" do
        expect(subject).to permit(@admin_user, @issue_post)
        expect(subject).to permit(@admin_user, @idea_post)
        expect(subject).to permit(@admin_user, @progress_post)
        expect(subject).to permit(@admin_user, @task_post)
      end
    end

    context "as an owner user" do
      it "is permitted to view any post" do
        expect(subject).to permit(@owner_user, @issue_post)
        expect(subject).to permit(@owner_user, @idea_post)
        expect(subject).to permit(@owner_user, @progress_post)
        expect(subject).to permit(@owner_user, @task_post)
      end
    end
  end

  permissions :create? do

    context "as an anonymous user" do
      it "is not permitted" do
        expect(subject).to_not permit(nil, @issue_post)
        expect(subject).to_not permit(nil, @idea_post)
        expect(subject).to_not permit(nil, @progress_post)
        expect(subject).to_not permit(nil, @task_post)
      end
    end

    context "as a regular user" do
      it "is permitted to add an issue" do
        expect(subject).to permit(@regular_user, @issue_post)
      end

      it "is not permitted to add an idea" do
        expect(subject).to_not permit(@regular_user, @idea_post)
      end

      it "is not permitted to add progress" do
        expect(subject).to_not permit(@regular_user, @progress_post)
      end

      it "is not permitted to add a task" do
        expect(subject).to_not permit(@regular_user, @task_post)
      end
    end

    context "as a pending user" do
      it "is permitted to add an issue" do
        expect(subject).to permit(@pending_user, @issue_post)
      end

      it "is not permitted to add an idea" do
        expect(subject).to_not permit(@pending_user, @idea_post)
      end

      it "is not permitted to add progress" do
        expect(subject).to_not permit(@pending_user, @progress_post)
      end

      it "is not permitted to add a task" do
        expect(subject).to_not permit(@pending_user, @task_post)
      end
    end

    context "as a collaborator" do
      it "is permitted to add an issue" do
        expect(subject).to permit(@collaborator_user, @issue_post)
      end

      it "is permitted to add an idea" do
        expect(subject).to permit(@collaborator_user, @idea_post)
      end

      it "is permitted to add progress" do
        expect(subject).to permit(@collaborator_user, @progress_post)
      end

      it "is permitted to add a task" do
        expect(subject).to permit(@collaborator_user, @task_post)
      end
    end

    context "as an admin" do
      it "is permitted to add an issue" do
        expect(subject).to permit(@admin_user, @issue_post)
      end

      it "is permitted to add an idea" do
        expect(subject).to permit(@admin_user, @idea_post)
      end

      it "is permitted to add progress" do
        expect(subject).to permit(@admin_user, @progress_post)
      end

      it "is permitted to add a task" do
        expect(subject).to permit(@admin_user, @task_post)
      end
    end

    context "as an owner" do
      it "is permitted to add an issue" do
        expect(subject).to permit(@owner_user, @issue_post)
      end

      it "is permitted to add an idea" do
        expect(subject).to permit(@owner_user, @idea_post)
      end

      it "is permitted to add progress" do
        expect(subject).to permit(@owner_user, @progress_post)
      end

      it "is permitted to add a task" do
        expect(subject).to permit(@owner_user, @task_post)
      end
    end
  end

  permissions :update? do

    context "as an anonymous user" do
      it "is not permitted to update a post" do
        expect(subject).to_not permit(nil, @idea_post)
        expect(subject).to_not permit(nil, @progress_post)
        expect(subject).to_not permit(nil, @task_post)
        expect(subject).to_not permit(nil, @issue_post)
      end
    end

    context "as a regular user" do
      it "is not permitted to update other's posts" do
        expect(subject).to_not permit(@regular_user, @idea_post)
        expect(subject).to_not permit(@regular_user, @progress_post)
        expect(subject).to_not permit(@regular_user, @task_post)
        expect(subject).to_not permit(@regular_user, @issue_post)
      end

      it "is permitted to update their own posts" do
        expect(subject).to permit(@regular_user, create(:post, user: @regular_user, post_type: "issue", project: @project))
      end
    end

    context "as a pending user" do
      it "is not permitted to update a post" do
        expect(subject).to_not permit(@pending_user, @idea_post)
        expect(subject).to_not permit(@pending_user, @progress_post)
        expect(subject).to_not permit(@pending_user, @task_post)
        expect(subject).to_not permit(@pending_user, @issue_post)
      end

      it "is permitted to update their own posts" do
        expect(subject).to permit(@pending_user, create(:post, user: @pending_user, post_type: "issue", project: @project))
      end
    end

    context "as a collaborator" do
      it "is not permitted to update a post" do
        expect(subject).to_not permit(@collaborator_user, @idea_post)
        expect(subject).to_not permit(@collaborator_user, @progress_post)
        expect(subject).to_not permit(@collaborator_user, @task_post)
        expect(subject).to_not permit(@collaborator_user, @issue_post)
      end

      it "is permitted to update their own posts" do
        expect(subject).to permit(@collaborator_user, create(:post, user: @collaborator_user, post_type: "idea", project: @project))
        expect(subject).to permit(@collaborator_user, create(:post, user: @collaborator_user, post_type: "progress", project: @project))
        expect(subject).to permit(@collaborator_user, create(:post, user: @collaborator_user, post_type: "task", project: @project))
        expect(subject).to permit(@collaborator_user, create(:post, user: @collaborator_user, post_type: "issue", project: @project))
      end
    end

    context "as an admin" do
      it "is permitted to update a post" do
        expect(subject).to permit(@admin_user, @idea_post)
        expect(subject).to permit(@admin_user, @progress_post)
        expect(subject).to permit(@admin_user, @task_post)
        expect(subject).to permit(@admin_user, @issue_post)
      end
    end

    context "as an owner" do
      it "is permitted to update a post" do
        expect(subject).to permit(@owner_user, @idea_post)
        expect(subject).to permit(@owner_user, @progress_post)
        expect(subject).to permit(@owner_user, @task_post)
        expect(subject).to permit(@owner_user, @issue_post)
      end
    end
  end
end
