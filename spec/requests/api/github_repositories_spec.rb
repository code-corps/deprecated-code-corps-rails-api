require 'rails_helper'

describe "GithubRepositories API" do

  describe "POST /github_repositories" do

    context "when unauthenticated" do
      it "responds with a 401" do
        post "#{host}/github_repositories", { data: { } }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

      before do
        @user = create(:user, email: "josh@coderly.com", password: "password")
        @organization = create(:organization)
        @project = create(:project, organization: @organization)
      end

      context "when user has insufficient access rights" do
        it "responds with a 401" do
          authenticated_post "/github_repositories", { data: {
            attributes: { url: "https://github.com/code-corps/code-corps-api" },
            relationships: { project: { data: { type: "projects", id: @project.id } } }
          } }, token

          expect(last_response.status).to eq 401
          expect(json).to be_a_valid_json_api_error.with_id "ACCESS_DENIED"
        end
      end

      context "when user has sufficient access rights" do
        before do
          create(:organization_membership, member: @user, organization: @organization, role: "admin")
        end

        context "when creation is succesful" do
          before do
            authenticated_post "/github_repositories", { data: {
              attributes: { url: "https://github.com/code-corps/code-corps-api" },
              relationships: { project: { data: { type: "projects", id: @project.id } } }
            } }, token
          end

          it "responds with a 200" do
            expect(last_response.status).to eq 200
          end

          it "responds with the created github_repository, serialized with GithubRepositorySerializer" do
            expect(json).to serialize_object(GithubRepository.last).with(GithubRepositorySerializer)
          end

          it "creates a new GithubRepository record" do
            expect(GithubRepository.last.repository_name).to eq "code-corps-api"
            expect(GithubRepository.last.owner_name).to eq "code-corps"
          end
        end

        context "when a project is not specified" do
          it "fails with a parameter missing error" do
            authenticated_post "/github_repositories", { data: {
              attributes: { url: "https://github.com/code-corps/code-corps-api" },
              relationships: {}
            } }, token
            expect(last_response.status).to eq 400
            expect(json).to be_a_valid_json_api_error.with_id "PARAMETER_MISSING"
          end
        end

        context "when a url is not specified" do
          it "fails with a parameter missing error" do
            authenticated_post "/github_repositories", { data: {
              relationships: { project: { data: { type: "projects", id: @project.id } } }
            } }, token
            expect(last_response.status).to eq 400
            expect(json).to be_a_valid_json_api_error.with_id "PARAMETER_MISSING"
          end
        end
      end
    end
  end
end
