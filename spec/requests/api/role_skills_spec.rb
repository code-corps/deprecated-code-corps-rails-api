require "rails_helper"

describe "RoleSkills API" do
  describe "POST /role_skills" do
    context "when unauthenticated" do
      it "responds with a 401" do
        post "#{host}/role_skills", data: {}
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

      before do
        @role = create(:role)
        @skill = create(:skill)
      end

      context "as a regular user" do
        before do
          create(:user, email: "josh@coderly.com", password: "password")
          authenticated_post "/role_skills", nil, token
        end

        it "responds with a 403" do
          expect(last_response.status).to eq 403
          expect(json).to be_a_valid_json_api_error.with_id "FORBIDDEN"
        end
      end

      context "as an admin user" do
        before do
          create(:user, email: "josh@coderly.com", password: "password", admin: true)
        end

        context "when creation is succesful" do
          before do
            authenticated_post "/role_skills", {
              data: {
                relationships: {
                  role: {
                    data: { type: "roles", id: @role.id }
                  },
                  skill: {
                    data: { type: "skills", id: @skill.id }
                  }
                }
              }
            }, token
          end

          it "responds with the created role_skill" do
            expect(last_response.status).to eq 200
          end

          it "sets role to provided role" do
            expect(json.data.relationships.role.data.id).to eq @role.id.to_s
            expect(RoleSkill.last.role).to eq @role
          end

          it "sets skill to provided skill" do
            expect(json.data.relationships.skill.data.id).to eq @skill.id.to_s
            expect(RoleSkill.last.skill).to eq @skill
          end

          it "includes role in the response" do
            expect(json.included).not_to be_nil

            included_roles = json.included.select { |i| i.type == "roles" }
            expect(included_roles.count).to eq 1
          end

          it "includes skill in the response" do
            expect(json.included).not_to be_nil

            included_roles = json.included.select { |i| i.type == "skills" }
            expect(included_roles.count).to eq 1
          end
        end

        context "when there's a role_skill with that pair of role_id and skill_id already" do
          before do
            create(:role_skill, role: @role, skill: @skill)
            authenticated_post "/role_skills", {
              data: {
                relationships: {
                  role: {
                    data: { type: "roles", id: @role.id }
                  },
                  skill: {
                    data: { type: "skills", id: @skill.id }
                  }
                }
              }
            }, token
          end

          it "fails with a validation error" do
            expect(last_response.status).to eq 422
            expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
          end
        end

        context "when there's no role with the specified id" do
          it "fails with a validation error" do
            authenticated_post "/role_skills", { data: { relationships: {
              role: { data: { type: "roles", id: 55 } }
            } } }, token

            expect(last_response.status).to eq 422
            expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
          end
        end

        context "when there's no skill with the specified id" do
          it "fails with a validation error" do
            authenticated_post "/role_skills", { data: { relationships: {
              skill: { data: { type: "skills", id: 55 } }
            } } }, token

            expect(last_response.status).to eq 422
            expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
          end
        end

        it "requires a skill to be specified" do
          authenticated_post "/role_skills", { data: { relationships: {} } }, token
          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
        end
      end
    end
  end
end
