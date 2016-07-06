require "rails_helper"

describe "Users API", :json_api do
  before(:each) do
    ActionMailer::Base.deliveries = []
  end

  context "GET /users" do
    before do
      create(:user, id: 1)
      create(:user, id: 2)
    end

    it "works" do
      get "#{host}/users", filter: { id: "1,2" }

      expect(last_response.status).to eq 200
      expect(json).to serialize_collection(User.find([1, 2])).
        with(UserSerializer).
        with_includes([:categories, :skills])
    end
  end

  context "GET /user" do
    context "when unauthenticated" do
      it "returns a 401 NOT_AUTHORIZED" do
        get "#{host}/user"

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "josh@example.com", password: "password") }

      before do
        @user = create(:user,
                       email: "josh@example.com",
                       username: "joshsmith",
                       password: "password")
        authenticated_get "user", {}, token
      end

      it "returns a proper response", aggregate_failures: true do
        expect(last_response.status).to eq 200
        expect(json).to serialize_object(@user).with(UserSerializer).with_scope(@user)
      end
    end
  end

  context "GET /users/email_available" do
    context "when unauthenticated" do
      context "when email is taken and valid" do
        let(:email) { "taken@example.com" }
        let!(:user) { create(:user, email: email) }

        it "returns the availability, case-insensitive" do
          get "#{host}/users/email_available", email: email.upcase

          expect(last_response.status).to eq 200
          expect(json.available).to eq false
          expect(json.valid).to eq true
        end
      end

      context "when email is available and invalid" do
        let(:email) { "available@" }

        it "returns the availability, case-insensitive" do
          get "#{host}/users/email_available", email: email.upcase

          expect(last_response.status).to eq 200
          expect(json.available).to eq true
          expect(json.valid).to eq false
        end
      end

      context "when email is available and valid" do
        let(:email) { "available@example.com" }

        it "returns the availability, case-insensitive" do
          get "#{host}/users/email_available", email: email.upcase

          expect(last_response.status).to eq 200
          expect(json.available).to eq true
          expect(json.valid).to eq true
        end
      end
    end
  end

  context "GET /users/username_available" do
    context "when unauthenticated" do
      context "when username is taken and valid" do
        let(:username) { "taken" }
        let!(:user) { create(:user, username: username) }

        it "returns the availability, case-insensitive" do
          get "#{host}/users/username_available", username: username.upcase

          expect(last_response.status).to eq 200
          expect(json.available).to eq false
          expect(json.valid).to eq true
        end
      end

      context "when username is available and invalid" do
        let(:username) { "available!" }

        it "returns the availability, case-insensitive" do
          get "#{host}/users/username_available", username: username.upcase

          expect(last_response.status).to eq 200
          expect(json.available).to eq true
          expect(json.valid).to eq false
        end
      end

      context "when username is available and valid" do
        let(:username) { "available" }

        it "returns the availability, case-insensitive" do
          get "#{host}/users/username_available", username: username.upcase

          expect(last_response.status).to eq 200
          expect(json.available).to eq true
          expect(json.valid).to eq true
        end
      end
    end
  end

  context "GET /users/:id" do
    before do
      @user = create(:user, username: "joshsmith")
      create_list(:user_skill, 2, user: @user)
      get "#{host}/users/#{@user.id}"
    end

    it "responds with a 200" do
      expect(last_response.status).to eq 200
    end

    it "responds with a properly serialized user" do
      expect(json).to serialize_object(@user).
        with(UserSerializer).
        with_includes([:skills, :projects])
    end
  end

  context "POST /users" do
    context "when registering through Facebook", :local_skip do
      before do
        oauth = Koala::Facebook::OAuth.new(
          ENV["FACEBOOK_APP_ID"],
          ENV["FACEBOOK_APP_SECRET"],
          ENV["FACEBOOK_REDIRECT_URL"])
        test_users = Koala::Facebook::TestUsers.new(
          app_id: ENV["FACEBOOK_APP_ID"], secret: ENV["FACEBOOK_APP_SECRET"])
        facebook_user = test_users.create(true, "email,user_friends")

        short_lived_token = facebook_user["access_token"]
        long_lived_token_info = oauth.exchange_access_token_info(short_lived_token)
        facebook_auth_code = oauth.generate_client_code(long_lived_token_info["access_token"])
        access_token_info = oauth.get_access_token_info(facebook_auth_code)

        @facebook_access_token = access_token_info["access_token"] ||
                                 JSON.parse(access_token_info.keys[0])["access_token"]
        @facebook_id = facebook_user["id"]
      end

      context "when parameters are valid" do
        before do
          params = {
            email: "josh@example.com",
            username: "joshsmith",
            password: "password",
            facebook_id: @facebook_id,
            facebook_access_token: @facebook_access_token
          }
          json_api_params = json_api_params_for("users", params)

          expect_any_instance_of(Analytics).to receive(:track_signed_up_with_facebook)

          post "#{host}/users", json_api_params
        end

        it "creates a valid user", vcr: { cassette_name: "requests/api/users/valid_facebook_request" } do
          expect(User.last.email).to eq "josh@example.com"
          expect(User.last.username).to eq "joshsmith"
          expect(User.last.facebook_id).to eq @facebook_id
          expect(User.last.facebook_access_token).to eq @facebook_access_token
        end

        it "uses their Facebook photo", vcr: { cassette_name: "requests/api/users/valid_facebook_request" } do
          expect(AddFacebookProfilePictureWorker.jobs.size).to eq 1
        end

        it "responds with a 200", vcr: { cassette_name: "requests/api/users/valid_facebook_request" } do
          expect(last_response.status).to eq 200
        end

        it "returns the created user using UserSerializer", vcr: { cassette_name: "requests/api/users/valid_facebook_request" } do
          expect(json).to serialize_object(User.last).
            with(UserSerializer).
            with_includes("skills")
        end
      end
    end

    context "when registering directly" do
      it "creates a valid user" do
        params = { email: "josh@example.com", username: "joshsmith", password: "password" }
        json_api_params = json_api_params_for("users", params)

        expect_any_instance_of(Analytics).to receive(:track_signed_up_with_email)

        post "#{host}/users", json_api_params

        expect(last_response.status).to eq 200

        user_attributes = json.data.attributes

        expect(user_attributes.email).to be_nil
        expect(user_attributes.username).to eq "joshsmith"
        expect(user_attributes.password).to be_nil
      end
    end

    context "with invalid data" do
      it "fails when an organization has a slug matching the username" do
        create(:organization, name: "Code Corps")

        params = { email: "josh@example.com", username: "code-corps", password: "password" }
        json_api_params = json_api_params_for("users", params)

        post "#{host}/users", json_api_params

        expect(last_response.status).to eq 422

        expect(json).to be_a_valid_json_api_validation_error.
          with_message "has already been taken by an organization"
      end

      it "fails on a blank password and username" do
        params = { email: "josh@example.com", username: "", password: "" }
        json_api_params = json_api_params_for("users", params)

        post "#{host}/users", json_api_params

        expect(last_response.status).to eq 422

        expect(json).to be_a_valid_json_api_validation_error.
          with_messages ["can't be blank", "can't be blank"]
      end

      it "fails on a too long username" do
        params = { email: "josh@example.com", username: "A" * 40, password: "password" }
        json_api_params = json_api_params_for("users", params)

        post "#{host}/users", json_api_params

        expect(last_response.status).to eq 422

        expect(json).to be_a_valid_json_api_validation_error.
          with_message "is too long (maximum is 39 characters)"
      end

      it "fails on a username with invalid characters" do
        params = { email: "josh@example.com", username: "this-won't-work", password: "password" }
        json_api_params = json_api_params_for("users", params)

        post "#{host}/users", json_api_params

        expect(last_response.status).to eq 422

        expect(json).to be_a_valid_json_api_validation_error.
          with_message "may only contain alphanumeric characters, underscores, or single hyphens, and cannot begin or end with a hyphen or underscore"
      end

      it "fails on a username with profane content" do
        params = { email: "josh@example.com", username: "shit", password: "password" }
        json_api_params = json_api_params_for("users", params)

        post "#{host}/users", json_api_params

        expect(last_response.status).to eq 422

        expect(json).to be_a_valid_json_api_validation_error.with_message "may not be obscene"
      end
    end

    context "when user accounts are taken" do
      before do
        create(:user, email: "josh@example.com", username: "joshsmith", password: "password")
      end

      it "fails when the email is taken" do
        params = { email: "josh@example.com", username: "joshsmith", password: "password" }
        json_api_params = json_api_params_for("users", params)

        post "#{host}/users", json_api_params

        expect(last_response.status).to eq 422

        expect(json).to be_a_valid_json_api_validation_error.with_message "has already been taken"
      end

      it "fails when the username is taken" do
        params = { email: "newemail@gmail.com", username: "joshsmith", password: "password" }
        json_api_params = json_api_params_for("users", params)

        post "#{host}/users", json_api_params

        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_validation_error.with_message "has already been taken"
      end
    end

    context "when registering with an email and password" do
      it "creates a user with a user uploaded image" do
        file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", "r")
        base64_image = Base64.encode64(open(file, &:read))

        post "#{host}/users", data: {
          attributes: {
            email: "josh@example.com",
            username: "joshsmith",
            password: "password",
            base64_photo_data: base64_image
          }
        }

        expect(last_response.status).to eq 200

        user = User.last

        expect(user.username).to eq "joshsmith"
        expect(user.email).to eq "josh@example.com"

        expect(UpdateProfilePictureWorker.jobs.size).to eq 1
        expect(AddProfilePictureFromGravatarWorker.jobs.size).to eq 0
      end

      it "creates a user without a user uploaded image" do
        post "#{host}/users", data: {
          attributes: {
            email: "josh@example.com",
            username: "joshsmith",
            password: "password"
          }
        }

        expect(last_response.status).to eq 200

        user = User.last

        expect(user.username).to eq "joshsmith"
        expect(user.email).to eq "josh@example.com"

        expect(UpdateProfilePictureWorker.jobs.size).to eq 0
        expect(AddProfilePictureFromGravatarWorker.jobs.size).to eq 1
      end
    end
  end

  context "POST /users/forgot_password" do
    before do
      @user = create(:user, email: "existing-user@mail.com", password: "test_password")
    end

    it "returns the user when the email is found" do
      json_api_params = json_api_params_for("users", email: "existing-user@mail.com")
      post "#{host}/users/forgot_password", json_api_params

      expect(last_response.status).to eq 200

      user_attributes = json.data.attributes
      expect(user_attributes.email).to eq @user.email
    end

    it "returns an error when the email is not found" do
      json_api_params = json_api_params_for("users", email: "not-existing-user@mail.com")
      post "#{host}/users/forgot_password", json_api_params

      expect(last_response.status).to eq 422
      expect(json).to be_a_valid_json_api_validation_error
    end
  end

  context "POST /users/reset_password" do
    before do
      @user = create(:user, email: "existing-user@mail.com", password: "test_password")
    end

    it "resets the password when the authentication token is valid" do
      json_api_params = json_api_params_for("users", email: "existing-user@mail.com")
      post "#{host}/users/forgot_password", json_api_params

      user = User.first

      json_api_params = json_api_params_for(
        "users",
        confirmation_token: user.confirmation_token.to_s,
        password: "newpassword"
      )
      post "#{host}/users/reset_password", json_api_params

      expect(last_response.status).to eq 200
      token = authenticate(email: "existing-user@mail.com", password: "newpassword")
      expect(token).to_not be_nil
    end

    it "doesn't reset the password when the authentication token is not valid" do
      json_api_params = json_api_params_for("users", email: "existing-user@mail.com")
      post "#{host}/users/forgot_password", json_api_params

      json_api_params = json_api_params_for(
        "users",
        confirmation_token: "fakeconfirmationtoken",
        password: "newpassword")
      post "#{host}/users/reset_password", json_api_params

      expect(last_response.status).to eq 422
      expect(json).to be_a_valid_json_api_validation_error
    end
  end

  context "PATCH /users/:id" do
    before do
      @edited_user = create(:user,
                            website: "initial.com",
                            biography: "Initial",
                            twitter: "user")
      params = {
        first_name: "Josh", last_name: "Smith",
        website: "edit.com", biography: "Edited", twitter: "edit",
        email: "new@mail.com", encrypted_password: "bla", confirmation_token: "bla",
        remember_token: "bla", username: "bla", admin: true
      }
      @edit_params = json_api_params_for("users", params)
    end

    context "when unauthenticated" do
      it "returns a 401 with a proper error message" do
        patch "#{host}/users/#{@edited_user.id}", @edit_params

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id("NOT_AUTHORIZED")
      end
    end

    context "when authenticated" do
      context "as an admin" do
        before do
          @admin = create(:user, admin: true, email: "admin@mail.com", password: "password")
          @token = authenticate(email: "admin@mail.com", password: "password")
        end

        it "performs the edit" do
          params = {
            data: {
              type: "users",
              attributes: {
                first_name: "Josh",
                last_name: "Smith",
                website: "edit.com",
                biography: "Edited",
                twitter: "edit",
                theme: "dark"
              }
            }
          }

          authenticated_patch "/users/#{@edited_user.id}", params, @token

          expect(last_response.status).to eq 200

          user_json = json.data.attributes
          expect(user_json.website).to eq "http://edit.com"
          expect(user_json.first_name).to eq "Josh"
          expect(user_json.last_name).to eq "Smith"
          expect(user_json.biography).to eq "Edited"
          expect(user_json.twitter).to eq "edit"
          expect(user_json.theme).to eq "dark"

          user = @edited_user.reload
          expect(user.website).to eq "http://edit.com"
          expect(user.first_name).to eq "Josh"
          expect(user.last_name).to eq "Smith"
          expect(user.biography).to eq "Edited"
          expect(user.twitter).to eq "edit"
          expect(user.theme).to eq "dark"
        end

        it "allows updating of only specific parameters" do
          expect_any_instance_of(User).to receive(:assign_attributes).with(
            first_name: "Josh",
            last_name: "Smith",
            website: "edit.com",
            biography: "Edited",
            twitter: "edit"
          )
          authenticated_patch "/users/#{@edited_user.id}", @edit_params, @token
        end

        it "renders validation errors if parameter values are invalid" do
          invalid_params = json_api_params_for("users", website: "multi word")
          authenticated_patch "/users/#{@edited_user.id}", invalid_params, @token
          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_validation_error
        end
      end

      context "as another user" do
        before do
          @regular_user = create(:user,
                                 admin: false,
                                 email: "regular@mail.com",
                                 password: "password")
          @token = authenticate(email: "regular@mail.com", password: "password")
        end

        it "returns a 403 FORBIDDEN" do
          authenticated_patch "/users/#{@edited_user.id}", @edit_params, @token

          expect(last_response.status).to eq 403
          expect(json).to be_a_valid_json_api_error.with_id("FORBIDDEN")
        end
      end
    end
  end

  context "PATCH /users/me" do
    before do
      @current_user = create(:user,
                             email: "current@mail.com",
                             password: "password",
                             website: "initial.com",
                             biography: "Initial",
                             twitter: "user")
      file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", "r")
      @base64_image = Base64.encode64(open(file, &:read))
      params = {
        first_name: "Josh",
        last_name: "Smith",
        website: "edit.com",
        biography: "Edited",
        twitter: "edit",
        email: "new@mail.com",
        encrypted_password: "bla",
        confirmation_token: "bla",
        remember_token: "bla",
        username: "bla",
        base64_photo_data: @base64_image,
        admin: true
      }
      @edit_params = json_api_params_for("users", params)
    end

    context "when unauthenticated" do
      it "returns a 401 with a proper error message" do
        patch "#{host}/users/me", @edit_params

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id("NOT_AUTHORIZED")
      end
    end

    context "when authenticated" do
      before do
        @token = authenticate(email: "current@mail.com", password: "password")
      end

      it "performs the edit" do
        authenticated_patch "/users/me", @edit_params, @token

        expect(last_response.status).to eq 200

        user_json = json.data.attributes
        expect(user_json.first_name).to eq "Josh"
        expect(user_json.last_name).to eq "Smith"
        expect(user_json.name).to eq "Josh Smith"
        expect(user_json.website).to eq "http://edit.com"
        expect(user_json.biography).to eq "Edited"
        expect(user_json.twitter).to eq "edit"

        current_user = @current_user.reload
        expect(current_user.website).to eq "http://edit.com"
        expect(current_user.first_name).to eq "Josh"
        expect(current_user.last_name).to eq "Smith"
        expect(current_user.biography).to eq "Edited"
        expect(current_user.twitter).to eq "edit"
        expect(UpdateProfilePictureWorker.jobs.size).to eq 1
      end

      it "allows updating of only specific parameters" do
        expect_any_instance_of(User).to receive(:assign_attributes).
          with(
            first_name: "Josh",
            last_name: "Smith",
            website: "edit.com",
            biography: "Edited",
            twitter: "edit",
            base64_photo_data: @base64_image
          )
        authenticated_patch "/users/me", @edit_params, @token
      end

      it "transitions the user's state" do
        params = json_api_params_for("users", state_transition: "edit_profile")
        authenticated_patch "/users/me", params, @token
        expect(last_response.status).to eq 200
        expect(User.last.state).to eq "edited_profile"
      end

      it "renders validation errors if parameter values are invalid" do
        invalid_params = json_api_params_for("users", website: "multi word")
        authenticated_patch "/users/me", invalid_params, @token
        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_validation_error
      end

      it "renders validation errors if the transition is invalid" do
        params = json_api_params_for("users", state_transition: "select_skills")
        authenticated_patch "/users/me", params, @token
        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_validation_error
      end
    end
  end
end
