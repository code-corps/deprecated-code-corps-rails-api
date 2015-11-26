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
            user: { data: { type: "users", id: @user.id } },
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

        it "includes user in the response"
        it "includes skill in the response"
      end

      context "when there's a user_skill with that pair of user_id and skill_id already" do
        it "cannot create a duplicate user_skill"
      end

      it "can create a new skill"
    end
  end

  describe "DELETE /user_skills/:id" do
    before do
      create(:user_skill, id: 1)
    end

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

      it "requires the user to be the current user"

      context "when deletion is successful" do
        it "deletes the user_skill"
        it "leaves user and skill untouched"
      end
    end
  end
end
