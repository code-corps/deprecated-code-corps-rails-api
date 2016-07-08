require "rails_helper"

describe "UserSkills API", :json_api do
  context "GET /user_skills" do
    context "with filter ids" do
      before do
        create(:user_skill, id: 1)
        create(:user_skill, id: 2)
        create(:user_skill, id: 3)
        get "#{host}/user_skills", filter: { id: "1,2" }
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "responds with a properly serialized collection" do
        expect(json).to serialize_collection(UserSkill.find([1, 2])).
          with(UserSkillSerializer)
      end
    end

    context "without filter ids" do
      context "when unauthenticated" do
        before do
          get "#{host}/user_skills"
        end

        it "responds with a 200" do
          expect(last_response.status).to eq 200
        end

        it "responds with a properly serialized collection" do
          expect(json).to serialize_collection([]).
            with(UserSkillSerializer)
        end
      end

      context "when authenticated" do
        let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

        before do
          @user = create(:user, email: "josh@coderly.com", password: "password")
          @user_skills = create_list(:user_skill, 3, user: @user)
          authenticated_get "/user_skills", nil, token
        end

        it "responds with a 200" do
          expect(last_response.status).to eq 200
        end

        it "responds with a properly serialized collection" do
          expect(json).to serialize_collection(@user_skills).
            with(UserSkillSerializer)
        end
      end
    end
  end

  context "GET /user_skills/:id" do
    before do
      @user_skill = create(:user_skill)
      get "#{host}/user_skills/#{@user_skill.id}"
    end

    it "responds with a 200" do
      expect(last_response.status).to eq 200
    end

    it "responds with a properly serialized user skill" do
      expect(json).to serialize_object(@user_skill).
        with(UserSkillSerializer)
    end
  end

  describe "POST /user_skills" do
    context "when unauthenticated" do
      it "responds with a 401" do
        post "#{host}/user_skills", data: {}
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
          expect_any_instance_of(Analytics).to receive(:track_added_user_skill)

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

          included_users = json.included.select { |i| i.type == "users" }
          expect(included_users.count).to eq 1
        end

        it "includes skill in the response" do
          expect(json.included).not_to be_nil

          included_users = json.included.select { |i| i.type == "skills" }
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

        expect(last_response.status).to eq 403
        expect(json).to be_a_valid_json_api_error.with_id "FORBIDDEN"
        expect(UserSkill.count).to eq 1
      end

      context "when deletion is successful" do
        before do
          user_skill = create(:user_skill, id: 1, user: @user)
          expect_any_instance_of(Analytics).to receive(:track_removed_user_skill).
            with(user_skill)
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
