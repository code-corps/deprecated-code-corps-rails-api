require 'rails_helper'

describe "passwords API" do

  describe "POST /passwords" do
    before do
      @user = create(:user, id: 10, email: 'existing-user@mail.com', password: 'test_password')
    end

    it "returns the user when the email is found" do
      post "#{host}/passwords", {
        user: {
          email: "existing-user@mail.com"
        }
      }
      expect(last_response.status).to eq 200
      expect(json.email).to eq @user.email
    end
    
    it "returns an error when the email is not found" do
      post "#{host}/passwords", {
        user: {
          email: "not-existing-user@mail.com"
        }
      }
      expect(last_response.status).to eq 422
      expect(json.errors.email).to include "doesn't exist"
    end
  end
end
