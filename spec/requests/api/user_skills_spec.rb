require 'rails_helper'

describe "UserSkills API" do


  describe "POST /user_skills" do

    context "when unauthenticated" do
      it "responds with a 401" do
        post "#{host}/user_skills", { data: { } }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

      before do
        @user = create(:user, email: "josh@coderly.com", password: "password")
        @skill = create(:skill)
      end

      context "when creation is succesful" do
        before do
          authenticated_post "/user_skills", { data: { relationships: {
            skill: { data: { type: "skills", id: @skill.id } }
          } } }, token
        end

        it "responds with the created user_skill" do
          expect(last_response.status).to eq 200
        end

        it "sets user to current user" do
          expect(json.data.relationships.user.data.id).to eq @user.id.to_s
          expect(UserSkill.last.user).to eq @user
        end

        it "sets skill to provided skill" do
          expect(json.data.relationships.skill.data.id).to eq @skill.id.to_s
          expect(UserSkill.last.skill).to eq @skill
        end

        it "includes user in the response" do
          expect(json.included).not_to be_nil

          included_users = json.included.select{ |i| i.type == "users" }
          expect(included_users.count).to eq 1
        end

        it "includes skill in the response" do
          expect(json.included).not_to be_nil

          included_users = json.included.select{ |i| i.type == "skills" }
          expect(included_users.count).to eq 1
        end
      end

      context "when there's a user_skill with that pair of user_id and skill_id already" do
        before do
          create(:user_skill, user: @user, skill: @skill)
          authenticated_post "/user_skills", { data: { relationships: {
            skill: { data: { type: "skills", id: @skill.id } }
          } } }, token
        end

        it "fails with a validation error" do
          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
        end
      end

      context "when there's no skill with the specified id" do
        it "fails with a validation error" do
          authenticated_post "/user_skills", { data: { relationships: {
            skill: { data: { type: "skills", id: 55 } }
          } } }, token

          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
        end
      end

      it "requires a skill to be specified" do
        authenticated_post "/user_skills", { data: { relationships: {} } }, token
        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
      end
    end
  end

  describe "DELETE /user_skills/:id" do
    context "when unauthenticated" do
      it "responds with a 401" do
        delete "#{host}/user_skills/1"

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do

      let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

      before do
        @user = create(:user, email: "josh@coderly.com", password: "password")
      end

      it "requires the user to be the current user" do
        create(:user_skill, id: 1)

        authenticated_delete "/user_skills/1", {}, token

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "ACCESS_DENIED"
        expect(UserSkill.count).to eq 1
      end

      context "when deletion is successful" do
        before do
          create(:user_skill, id: 1, user: @user)
          authenticated_delete "/user_skills/1", {}, token
        end

        it "responds with a 204" do
          expect(last_response.status).to eq 204
        end

        it "deletes the user_skill" do
          expect(UserSkill.count).to eq 0
        end

        it "leaves user and skill untouched" do
          expect(User.count).to eq 1
          expect(Skill.count).to eq 1
        end
      end
    end
  end
end
