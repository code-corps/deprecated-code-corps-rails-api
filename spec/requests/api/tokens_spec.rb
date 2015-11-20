require 'rails_helper'

describe "Tokens API" do

  describe "POST /oauth/tokens" do

    context "with an email and password" do
      before do
        @user = create(:user, id: 10, email: 'existing-user@mail.com', password: 'test_password')
      end

      it "returns a token when both email and password are valid" do
        post "#{host}/oauth/token", {
          grant_type: "password",
          username: 'existing-user@mail.com',
          password: 'test_password'
        }
        expect(last_response.status).to eq 200
        expect(json.access_token).not_to be nil
      end

      it "fails with 401 when email is invalid" do
        post "#{host}/oauth/token", {
          grant_type: "password",
          username: 'invalid-email@mail.com',
          password: 'test_password'
        }

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "INVALID_GRANT"
      end

      it "fails with 401 when password is invalid" do
        post "#{host}/oauth/token", {
          grant_type: "password",
          username: 'existing-user@mail.com',
          password: 'invalid_password'
        }

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "INVALID_GRANT"
      end
    end
  end
end
