require "rails_helper"

describe "Contributors API" do

  context "GET /contributors" do
    before do
      @project = create(:project)
      create_list(:contributor, 10, project: @project)
      create_list(:contributor, 5)
    end

    it "responds with a 400 if no filter is specified" do
      get "#{host}/contributors"
      expect(last_response.status).to eq 400
      expect(json).to be_a_valid_json_api_error.with_id "PARAMETER_MISSING"
    end

    context "when successful" do
      before do
        get "#{host}/contributors", { filter: { project_id: @project.id } }
      end

      it "returns a list of contributors for a project" do
        expect(last_response.status).to eq 200
        expect(json.data.length).to eq 10
      end

      it "includes users" do
        expect(json.included).not_to be_nil
        users = json.included.select { |i| i.type == "users" }
        expect(users.count).to eq 10
      end
      it "includes project" do
        expect(json.included).not_to be_nil
        projects = json.included.select { |i| i.type == "projects" }
        expect(projects.count).to eq 1
        expect(projects.first.id).to eq @project.id.to_s
      end
    end

  end

  context "POST /contributors" do
    context "when unauthenticated" do
      it "should return a 401 with a proper error" do
        post "#{host}/contributors", { data: { type: "contributors" } }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      before do
        @user = create(:user, email: "test_user@mail.com", password: "password")
        @token = authenticate(email: "test_user@mail.com", password: "password")
        @project = create(:project)
      end

      it "requires a project to be specified" do
        authenticated_post "/contributors", { data: {
          type: "contributors"
        } }, @token

        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_error
        expect(json).to contain_an_error_of_type("VALIDATION_ERROR").with_message("Project can't be blank")
      end

      context "when contributor record for project and user already exists" do
        before do
          create(:contributor, user: @user, project: @project)
        end

        it "fails with a 422" do
          authenticated_post "/contributors", { data: {
            type: "contributors",
            relationships: {
              project: { data: { id: @project.id, type: "projects" } }
            }
          } }, @token

          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error
          expect(json).to contain_an_error_of_type("VALIDATION_ERROR").with_message("User has already been taken")
        end

      end

      context "when successful" do
        before do
          authenticated_post "/contributors", { data: {
            type: "contributors",
            relationships: {
              project: { data: { id: @project.id, type: "projects" } }
            }
          } }, @token
        end

        it "responds with a 200" do
          expect(last_response.status).to eq 200
        end

        it "returns the created contributor" do
          expect(json.data.attributes).not_to be_nil
          expect(json.data.type).to eq "contributors"
        end

        it "sets contributor user to current user" do
          contributor_user = json.data.relationships.user
          expect(contributor_user).not_to be_nil
          expect(contributor_user.data.id).to eq @user.id.to_s
        end

        it "sets contributor project to specified project" do
          contributor_project = json.data.relationships.project
          expect(contributor_project).not_to be_nil
          expect(contributor_project.data.id).to eq @project.id.to_s
        end

        it "sets contributor status to 'pending'" do
          expect(json.data.attributes.status).to eq "pending"
        end

        it "includes the user"
        it "includes the project"
      end
    end
  end

  context 'PATCH /contributors/:id' do
    it "requires authentication"

    it "allows a project admin to change 'pending' to 'collaborator'"

    it "does not allow a project admin to change anything to 'admin'"
    it "does not allow a project admin to change anything to 'owner'"
    it "does not allow a project admin to change anything to 'pending'"
    it "does not allow a project admin to change to anything from 'admin'"
    it "does not allow a project admin to change to anything from 'owner'"
    it "does not allow a project admin to change to anything from 'collaborator'"

    it "allows a project owner to change 'pending' to 'collaborator'"
    it "allows a project owner to change 'collaborator' to 'admin'"
    it "allows a project owner to change 'admin' to 'collaborator'"

    it "does not allow a project owner to change anything to 'pending'"

    it "does not allow a project owner to change anything to 'owner'"
    it "does not allow a project owner to change to anything from 'owner'"

    it "returns the updated contributor"
  end
end
