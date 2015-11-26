require 'rails_helper'

describe "UserSkills API" do

  let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

  describe "POST /user_skills" do

    context "when unauthenticated" do
      it "responds with a 401" do
        post "#{host}/user_skills", { data: { } }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      context "when creation is succesful" do
        it "responds with the created user_skill"
        it "sets user to current user"
        it "sets skill to provided skill"
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

      it "requires the user to be the current user"

      context "when deletion is successful" do
        it "deletes the user_skill"
        it "leaves user and skill untouched"
      end
    end
  end
end
