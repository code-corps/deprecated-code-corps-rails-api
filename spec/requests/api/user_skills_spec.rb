require 'rails_helper'

describe "UserSkills API" do

  let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

  describe "POST /user_skills" do
    it "requires authentication"
    it "sets user to current user"
    it "sets skill to provided skill"
    it "can create a new skill"
  end

  describe "DELETE /user_skills" do
    it "requires authentication"
    it "requires the user to be the current user"
    it "deletes the user_skill"
    it "leaves user and skill untouched"
  end
end
