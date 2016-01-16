require 'rails_helper'

describe PostPolicy do

  subject { described_class }

  before do
    @organization = create(:organization)

    @project = create(:project, owner: @organization)

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

    @idea_post = create(:post,
                        post_type: "idea",
                        project: @project)

    @progress_post = create(:post,
                            post_type: "progress",
                            project: @project)

    @task_post = create(:post,
                        post_type: "task",
                        project: @project)

    @issue_post = create(:post,
                         post_type: "issue",
                         project: @project)
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

    context "as a contributor user" do
      it "is permitted to view any post" do
        expect(subject).to permit(@contributor_user, @issue_post)
        expect(subject).to permit(@contributor_user, @idea_post)
        expect(subject).to permit(@contributor_user, @progress_post)
        expect(subject).to permit(@contributor_user, @task_post)
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

    context "as a pending user" do
      it "is not permitted to create others' posts" do
        expect(subject).to_not permit(@pending_user, @issue_post)
        expect(subject).to_not permit(@pending_user, @idea_post)
        expect(subject).to_not permit(@pending_user, @progress_post)
        expect(subject).to_not permit(@pending_user, @task_post)
      end

      it "is permitted to add an issue" do
        post = create(:post,
                      user: @pending_user,
                      post_type: "issue",
                      project: @project)
        expect(subject).to permit(@pending_user, post)
      end

      it "is not permitted to add an idea" do
        post = create(:post,
                      user: @pending_user,
                      post_type: "idea",
                      project: @project)
        expect(subject).not_to permit(@pending_user, post)
      end

      it "is not permitted to add progress" do
        post = create(:post,
                      user: @pending_user,
                      post_type: "progress",
                      project: @project)
        expect(subject).not_to permit(@pending_user, post)
      end

      it "is not permitted to add a task" do
        post = create(:post,
                      user: @pending_user,
                      post_type: "task",
                      project: @project)
        expect(subject).not_to permit(@pending_user, post)
      end
    end

    context "as a contributor" do
      it "is not permitted to create others' posts" do
        expect(subject).to_not permit(@contributor_user, @issue_post)
        expect(subject).to_not permit(@contributor_user, @idea_post)
        expect(subject).to_not permit(@contributor_user, @progress_post)
        expect(subject).to_not permit(@contributor_user, @task_post)
      end

      it "is permitted to add an issue" do
        post = create(:post,
                      user: @contributor_user,
                      post_type: "issue",
                      project: @project)
        expect(subject).to permit(@contributor_user, post)
      end

      it "is permitted to add an idea" do
        post = create(:post,
                      user: @contributor_user,
                      post_type: "idea",
                      project: @project)
        expect(subject).to permit(@contributor_user, post)
      end

      it "is permitted to add progress" do
        post = create(:post,
                      user: @contributor_user,
                      post_type: "progress",
                      project: @project)
        expect(subject).to permit(@contributor_user, post)
      end

      it "is permitted to add a task" do
        post = create(:post,
                      user: @contributor_user,
                      post_type: "task",
                      project: @project)
        expect(subject).to permit(@contributor_user, post)
      end
    end

    context "as an admin" do
      it "is not permitted to create others' posts" do
        expect(subject).to_not permit(@admin_user, @issue_post)
        expect(subject).to_not permit(@admin_user, @idea_post)
        expect(subject).to_not permit(@admin_user, @progress_post)
        expect(subject).to_not permit(@admin_user, @task_post)
      end

      it "is permitted to add an issue" do
        post = create(:post,
                      user: @admin_user,
                      post_type: "issue",
                      project: @project)
        expect(subject).to permit(@admin_user, post)
      end

      it "is permitted to add an idea" do
        post = create(:post,
                      user: @admin_user,
                      post_type: "idea",
                      project: @project)
        expect(subject).to permit(@admin_user, post)
      end

      it "is permitted to add progress" do
        post = create(:post,
                      user: @admin_user,
                      post_type: "progress",
                      project: @project)
        expect(subject).to permit(@admin_user, post)
      end

      it "is permitted to add a task" do
        post = create(:post,
                      user: @admin_user,
                      post_type: "task",
                      project: @project)
        expect(subject).to permit(@admin_user, post)
      end
    end

    context "as an owner" do
      it "is not permitted to create others' posts" do
        expect(subject).to_not permit(@owner_user, @issue_post)
        expect(subject).to_not permit(@owner_user, @idea_post)
        expect(subject).to_not permit(@owner_user, @progress_post)
        expect(subject).to_not permit(@owner_user, @task_post)
      end

      it "is permitted to add an issue" do
        post = create(:post,
                      user: @owner_user,
                      post_type: "issue",
                      project: @project)
        expect(subject).to permit(@owner_user, post)
      end

      it "is permitted to add an idea" do
        post = create(:post,
                      user: @owner_user,
                      post_type: "idea",
                      project: @project)
        expect(subject).to permit(@owner_user, post)
      end

      it "is permitted to add progress" do
        post = create(:post,
                      user: @owner_user,
                      post_type: "progress",
                      project: @project)
        expect(subject).to permit(@owner_user, post)
      end

      it "is permitted to add a task" do
        post = create(:post,
                      user: @owner_user,
                      post_type: "task",
                      project: @project)
        expect(subject).to permit(@owner_user, post)
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

    context "as a pending user" do
      it "is not permitted to update others' post" do
        expect(subject).to_not permit(@pending_user, @idea_post)
        expect(subject).to_not permit(@pending_user, @progress_post)
        expect(subject).to_not permit(@pending_user, @task_post)
        expect(subject).to_not permit(@pending_user, @issue_post)
      end

      it "is permitted to update their own issues" do
        post = create(:post,
                      user: @pending_user,
                      post_type: "issue",
                      project: @project)
        expect(subject).to permit(@pending_user, post)
      end
    end

    context "as a contributor" do
      it "is not permitted to update others' posts" do
        expect(subject).to_not permit(@contributor_user, @idea_post)
        expect(subject).to_not permit(@contributor_user, @progress_post)
        expect(subject).to_not permit(@contributor_user, @task_post)
        expect(subject).to_not permit(@contributor_user, @issue_post)
      end

      it "is permitted to update their own issue" do
        post = create(:post,
                      user: @contributor_user,
                      post_type: "issue",
                      project: @project)
        expect(subject).to permit(@contributor_user, post)
      end

      it "is permitted to update their own idea" do
        post = create(:post,
                      user: @contributor_user,
                      post_type: "idea",
                      project: @project)
        expect(subject).to permit(@contributor_user, post)
      end

      it "is permitted to update their own progress" do
        post = create(:post,
                      user: @contributor_user,
                      post_type: "progress",
                      project: @project)
        expect(subject).to permit(@contributor_user, post)
      end

      it "is permitted to update their own task" do
        post = create(:post,
                      user: @contributor_user,
                      post_type: "task",
                      project: @project)
        expect(subject).to permit(@contributor_user, post)
      end
    end

    context "as an admin" do
      it "is permitted to update anyone's post" do
        expect(subject).to permit(@admin_user, @idea_post)
        expect(subject).to permit(@admin_user, @progress_post)
        expect(subject).to permit(@admin_user, @task_post)
        expect(subject).to permit(@admin_user, @issue_post)
      end
    end

    context "as an owner" do
      it "is permitted to update anyone's post" do
        expect(subject).to permit(@owner_user, @idea_post)
        expect(subject).to permit(@owner_user, @progress_post)
        expect(subject).to permit(@owner_user, @task_post)
        expect(subject).to permit(@owner_user, @issue_post)
      end
    end
  end
end
