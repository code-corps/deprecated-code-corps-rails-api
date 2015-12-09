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

        it "returns the created contributor, serialized with ContributorSerializer" do
          expect(json).to serialize_object(Contributor.last).with(ContributorSerializer)
        end

        it "sets contributor user to current user" do
          expect(Contributor.last.user).to eq @user
        end

        it "sets contributor project to specified project" do
          expect(Contributor.last.project).to eq @project
        end

        it "sets contributor status to 'pending'" do
          expect(Contributor.last.pending?).to be true
        end
      end
    end
  end

  context 'PATCH /contributors/:id' do
    before do
      @user = create(:user, email: "test_user@mail.com", password: "password")
      @project = create(:project)
    end

    context "when unauthenticated" do
      it "should return a 401 with a proper error" do
        patch "#{host}/contributors/1", { data: { type: "contributors" } }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do

      before do
        @token = authenticate(email: "test_user@mail.com", password: "password")
      end

      context "when attempting to update a non-existing record" do
        it "responds with a 404" do
          authenticated_patch "/contributors/invalid", { data: {
            type: "contributors"
          } }, @token

          expect(last_response.status).to eq 404
          expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
        end
      end

      context "when it's succesful" do

        it "returns the updated contributor" do
          create(:contributor, user: @user, project: @project, status: "admin")
          contributor = create(:contributor, project: @project)
          authenticated_patch "/contributors/#{contributor.id}", { data: {
            type: "contributors",
            attributes: { status: "collaborator" }
          } }, @token

          expect(last_response.status).to eq 200
          expect(json.data.id).to eq contributor.id.to_s
          expect(json.data.type).to eq "contributors"
          expect(json.data.attributes.status).to eq "collaborator"
        end
      end
    end

  end
end
