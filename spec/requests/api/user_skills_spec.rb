require 'rails_helper'

describe "UserSkills API" do

  let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

  describe "POST /user_skills" do

    it "requires authentication" do
      post "#{host}/user_skills", { data: { } }
      expect(last_response.status).to eq 401
      expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
    end

    it "sets user to current user"
    it "sets skill to provided skill"
    it "can create a new skill"
    it "cannot create a duplicate user_skill"
  end

  describe "DELETE /user_skills/:id" do
    before do
      create(:user_skill, id: 1)
    end

    it "requires authentication" do
      delete "#{host}/user_skills/1"

      expect(last_response.status).to eq 401
      expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
    end

    it "requires the user to be the current user"
    it "deletes the user_skill"
    it "leaves user and skill untouched"
  end
end
