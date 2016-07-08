require "rails_helper"

describe "ProjectSkills API", :json_api do
  describe "POST /project_skills" do
    context "when unauthenticated" do
      it "responds with a 401" do
        post "#{host}/project_skills", data: {}
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
        @skill = create(:skill)
        create(:organization_membership, role: "admin", member: @user, organization: organization)
      end

      context "when creation is succesful" do
        before do
          authenticated_post "/project_skills", { data: { relationships: {
            project: {
              data: {
                type: "projects", id: @project.id
              }
            },
            skill: {
              data: {
                type: "skills", id: @skill.id
              }
            }
          } } }, token
        end

        it "responds with the created project_skill" do
          expect(last_response.status).to eq 200
        end

        it "sets skill to current skill" do
          expect(json.data.relationships.skill.data.id).to eq @skill.id.to_s
          expect(ProjectSkill.last.skill).to eq @skill
        end

        it "sets project to provided project" do
          expect(json.data.relationships.project.data.id).to eq @project.id.to_s
          expect(ProjectSkill.last.project).to eq @project
        end

        it "includes skill in the response" do
          expect(json.included).not_to be_nil

          included_skills = json.included.select { |i| i.type == "skills" }
          expect(included_skills.count).to eq 1
        end

        it "includes project in the response" do
          expect(json.included).not_to be_nil

          included_skills = json.included.select { |i| i.type == "projects" }
          expect(included_skills.count).to eq 1
        end
      end

      context "when that project_skill already exists" do
        before do
          create(:project_skill, skill: @skill, project: @project)
          authenticated_post "/project_skills", { data: { relationships: {
            project: {
              data: {
                type: "projects", id: @project.id
              }
            },
            skill: {
              data: {
                type: "skills", id: @skill.id
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
          authenticated_post "/project_skills", { data: { relationships: {
            project: { data: { type: "projects", id: 55 } },
            skill: {
              data: {
                type: "skills", id: @skill.id
              }
            }
          } } }, token

          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
        end
      end

      it "requires a skill to be specified" do
        authenticated_post "/project_skills", { data: { relationships: {} } }, token
        expect(last_response.status).to eq 400
        expect(json).to be_a_valid_json_api_error.with_id "PARAMETER_MISSING"
      end

      it "requires a project to be specified" do
        authenticated_post "/project_skills", { data: { relationships: {
          skill: {
            data: {
              type: "skills", id: @skill.id
            }
          }
        } } }, token
        expect(last_response.status).to eq 400
        expect(json).to be_a_valid_json_api_error.with_id "PARAMETER_MISSING"
      end
    end
  end

  describe "DELETE /project_skills/:id" do
    context "when unauthenticated" do
      it "responds with a 401" do
        delete "#{host}/project_skills/1"

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
        @skill = create(:skill)
        create(:organization_membership, role: "admin", member: @user, organization: organization)
      end

      context "without admin access" do
        before do
          @user = create(:user, email: "random@user.com", password: "password")
        end

        let(:token) { authenticate(email: "random@user.com", password: "password") }

        it "returns a 403 FORBIDDEN" do
          create(:project_skill, id: 1, skill: @skill, project: @project)

          authenticated_delete "/project_skills/1", {}, token

          expect(last_response.status).to eq 403
          expect(json).to be_a_valid_json_api_error.with_id "FORBIDDEN"
          expect(ProjectSkill.count).to eq 1
        end
      end

      context "when deletion is successful" do
        before do
          create(:project_skill, id: 1, skill: @skill, project: @project)
          authenticated_delete "/project_skills/1", {}, token
        end

        it "responds with a 204" do
          expect(last_response.status).to eq 204
        end

        it "deletes the project_skill" do
          expect(ProjectSkill.count).to eq 0
        end

        it "leaves skill and project untouched" do
          expect(Skill.count).to eq 1
          expect(Project.count).to eq 1
        end
      end
    end
  end
end
