require "rails_helper"

describe "ProjectRoles API" do
  describe "POST /project_roles" do
    context "when unauthenticated" do
      it "responds with a 401" do
        post "#{host}/project_roles", data: {}
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

      before do
        @user = create(:user, email: "josh@coderly.com", password: "password")
        organization = create(:organization)
        @project = create(:project, organization: organization)
        @role = create(:role)
        create(:organization_membership, role: "admin", member: @user, organization: organization)
      end

      context "when creation is succesful" do
        before do
          authenticated_post "/project_roles", { data: { relationships: {
            project: {
              data: {
                type: "projects", id: @project.id
              }
            },
            role: {
              data: {
                type: "roles", id: @role.id
              }
            }
          } } }, token
        end

        it "responds with the created project_role" do
          expect(last_response.status).to eq 200
        end

        it "sets role to current role" do
          expect(json.data.relationships.role.data.id).to eq @role.id.to_s
          expect(ProjectRole.last.role).to eq @role
        end

        it "sets project to provided project" do
          expect(json.data.relationships.project.data.id).to eq @project.id.to_s
          expect(ProjectRole.last.project).to eq @project
        end

        it "includes role in the response" do
          expect(json.included).not_to be_nil

          included_roles = json.included.select { |i| i.type == "roles" }
          expect(included_roles.count).to eq 1
        end

        it "includes project in the response" do
          expect(json.included).not_to be_nil

          included_roles = json.included.select { |i| i.type == "projects" }
          expect(included_roles.count).to eq 1
        end
      end

      context "when that project_role already exists" do
        before do
          create(:project_role, role: @role, project: @project)
          authenticated_post "/project_roles", { data: { relationships: {
            project: {
              data: {
                type: "projects", id: @project.id
              }
            },
            role: {
              data: {
                type: "roles", id: @role.id
              }
            }
          } } }, token
        end

        it "fails with a validation error" do
          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
        end
      end

      context "when there's no project with the specified id" do
        it "fails with a validation error" do
          authenticated_post "/project_roles", { data: { relationships: {
            project: { data: { type: "projects", id: 55 } },
            role: {
              data: {
                type: "roles", id: @role.id
              }
            }
          } } }, token

          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
        end
      end

      it "requires a role to be specified" do
        authenticated_post "/project_roles", { data: { relationships: {} } }, token
        expect(last_response.status).to eq 400
        expect(json).to be_a_valid_json_api_error.with_id "PARAMETER_MISSING"
      end

      it "requires a project to be specified" do
        authenticated_post "/project_roles", { data: { relationships: {
          role: {
            data: {
              type: "roles", id: @role.id
            }
          }
        } } }, token
        expect(last_response.status).to eq 400
        expect(json).to be_a_valid_json_api_error.with_id "PARAMETER_MISSING"
      end
    end
  end

  describe "DELETE /project_roles/:id" do
    context "when unauthenticated" do
      it "responds with a 401" do
        delete "#{host}/project_roles/1"

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

      before do
        @user = create(:user, email: "josh@coderly.com", password: "password")
        organization = create(:organization)
        @project = create(:project, organization: organization)
        @role = create(:role)
        create(:organization_membership, role: "admin", member: @user, organization: organization)
      end

      context "without admin access" do
        before do
          @user = create(:user, email: "random@user.com", password: "password")
        end

        let(:token) { authenticate(email: "random@user.com", password: "password") }

        it "returns a 401 access denied" do
          create(:project_role, id: 1, role: @role, project: @project)

          authenticated_delete "/project_roles/1", {}, token

          expect(last_response.status).to eq 401
          expect(json).to be_a_valid_json_api_error.with_id "ACCESS_DENIED"
          expect(ProjectRole.count).to eq 1
        end
      end

      context "when deletion is successful" do
        before do
          create(:project_role, id: 1, role: @role, project: @project)
          authenticated_delete "/project_roles/1", {}, token
        end

        it "responds with a 204" do
          expect(last_response.status).to eq 204
        end

        it "deletes the project_role" do
          expect(ProjectRole.count).to eq 0
        end

        it "leaves role and project untouched" do
          expect(Role.count).to eq 1
          expect(Project.count).to eq 1
        end
      end
    end
  end
end
