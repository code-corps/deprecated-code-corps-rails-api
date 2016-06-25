require "rails_helper"

describe "Tokens API" do
  describe "POST /oauth/tokens" do
    context "with an email and password" do
      before do
        @user = create(:user, id: 10, email: "existing-user@mail.com", password: "test_password")
      end

      it "returns a token when both email and password are valid" do
        expect_any_instance_of(Analytics).to receive(:track_signed_in_with_email)

        post "#{host}/oauth/token", {
          grant_type: "password",
          username: "existing-user@mail.com",
          password: "test_password"
        }
        expect(last_response.status).to eq 200
        expect(json.access_token).not_to be nil
      end

      it "fails with 401 when email is invalid" do
        post "#{host}/oauth/token", {
          grant_type: "password",
          username: "invalid-email@mail.com",
          password: "test_password"
        }

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "INVALID_GRANT"
      end

      it "fails with 401 when password is invalid" do
        post "#{host}/oauth/token", {
          grant_type: "password",
          username: "existing-user@mail.com",
          password: "invalid_password"
        }

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "INVALID_GRANT"
      end
    end

    context "with a facebook_auth_code", local_skip: true do

      context "when facebook user doesn't exist", vcr: { cassette_name: "requests/api/tokens/facebook_user_not_found" } do
        it "fails with 400" do
          post "#{host}/oauth/token", {
            grant_type: "password",
            username: "facebook",
            password: "non-existant-token"
          }

          expect(last_response.status).to eq 400
          expect(json).to be_a_valid_json_api_error.with_id "FACEBOOK_AUTHENTICATION_ERROR"
        end
      end

      context "when facebook user does exist", local_skip: true, vcr: { cassette_name: "requests/api/tokens/facebook_user_found" } do
        before do
          oauth = Koala::Facebook::OAuth.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"], ENV["FACEBOOK_REDIRECT_URL"])
          test_users = Koala::Facebook::TestUsers.new(app_id: ENV["FACEBOOK_APP_ID"], secret: ENV["FACEBOOK_APP_SECRET"])
          facebook_user = test_users.create(true, "email,user_friends")

          short_lived_token = facebook_user["access_token"]
          long_lived_token_info = oauth.exchange_access_token_info(short_lived_token)
          facebook_auth_code = oauth.generate_client_code(long_lived_token_info["access_token"])
          access_token_info = oauth.get_access_token_info(facebook_auth_code)

          @facebook_access_token = access_token_info["access_token"] || JSON.parse(access_token_info.keys[0])["access_token"]
          @facebook_id = facebook_user["id"]
        end

        context "and theres a user with facebook_id in the database" do
          before do
            @user = create(:user, facebook_id: @facebook_id)
          end

          it "returns a token" do
            expect_any_instance_of(Analytics).to receive(:track_signed_in_with_facebook)

            post "#{host}/oauth/token", {
              grant_type: "password",
              username: "facebook",
              password: @facebook_access_token
            }

            expect(last_response.status).to eq 200
            expect(json.access_token).not_to be nil
          end
        end

        context "and theres no user with that facebook_id in the database" do
          it "fails with a 404" do
            post "#{host}/oauth/token", {
              grant_type: "password",
              username: "facebook",
              password: @facebook_access_token
            }

            expect(last_response.status).to eq 404
            expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
          end
        end
      end
    end
  end
end
