require 'rails_helper'

describe "Users API" do

  before(:each) do
    ActionMailer::Base.deliveries = []
  end

  context 'GET /user' do
    let(:token) { authenticate(email: "josh@example.com", password: "password") }

    before do
      create(:user, email: "josh@example.com", username: "joshsmith", password: "password")
    end

    context 'when authenticated' do
      it 'returns the authenticated user object' do
        authenticated_get "user", {}, token

        expect(last_response.status).to eq 200

        user_attributes = json.data.attributes

        expect(user_attributes.email).to eq "josh@example.com"
        expect(user_attributes.username).to eq "joshsmith"
        expect(user_attributes.password).to be_nil
      end
    end

    context 'when unauthenticated' do
      it 'returns a 401 unauthorized' do
        get "#{host}/user"

        expect(last_response.status).to eq 401

        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end
  end

  context 'GET /users' do
    before do
      @user = create(:user, email: "josh@example.com", username: "joshsmith", password: "password")
    end

    it 'returns a user object if the user exists' do
      get "#{host}/users/#{@user.id}",{}

      expect(last_response.status).to eq 200

      user_attributes = json.data.attributes

      expect(user_attributes.email).to eq "josh@example.com"
      expect(user_attributes.username).to eq "joshsmith"
      expect(user_attributes.password).to be_nil
    end
  end

  context 'POST /users' do

    it 'creates a valid user' do
      post "#{host}/users", {
        user: {
          email: "josh@example.com",
          username: "joshsmith",
          password: "password"
        }
      }

      expect(last_response.status).to eq 200

      user_attributes = json.data.attributes

      expect(user_attributes.email).to eq "josh@example.com"
      expect(user_attributes.username).to eq "joshsmith"
      expect(user_attributes.password).to be_nil
    end

    context 'with invalid data' do

      it 'fails on a blank password and username' do
        post "#{host}/users", {
          user: {
            email: "josh@example.com",
            password: "",
            username: ""
          }
        }

        expect(last_response.status).to eq 422

        expect(json.errors.password).to eq "can't be blank"
        expect(json.errors.username).to eq "can't be blank"
      end

      it 'fails on a too long username' do
        post "#{host}/users", {
          user: {
            email: "josh@example.com",
            password: "password",
            username: "thisusernameiswaytoolongforusbecauseitswelloverthelimit"
          }
        }

        expect(last_response.status).to eq 422

        expect(json.errors.username).to eq "is too long (maximum is 39 characters)"
      end

      it 'fails on a username with invalid characters' do
        post "#{host}/users", {
          user: {
            email: "josh@example.com",
            password: "password",
            username: "this-won't-work"
          }
        }

        expect(last_response.status).to eq 422

        expect(json.errors.username).to eq "is invalid. Alphanumerics only."
      end

    end

    context 'when user accounts are taken' do
      before do
        create(:user, email: "josh@example.com", username: "joshsmith", password: "password")
      end

      it 'fails when the email is taken' do
        post "#{host}/users", {
          user: {
            email: "josh@example.com",
            password: "password",
            username: "joshsmith"
          }
        }

        expect(last_response.status).to eq 422

        expect(json.errors.email).to eq "has already been taken"
      end

      it 'fails when the username is taken' do
        post "#{host}/users", {
          user: {
            email: "newemail@gmail.com",
            password: "password",
            username: "joshsmith"
          }
        }

        expect(last_response.status).to eq 422

        expect(json.errors.username).to eq "has already been taken"
      end
    end
  end

  context "POST /users/forgot_password" do

    before do
      @user = create(:user, id: 10, email: 'existing-user@mail.com', password: 'test_password')
    end

    it "returns the user when the email is found" do
      post "#{host}/users/forgot_password", {
        user: {
          email: "existing-user@mail.com"
        }
      }
      expect(last_response.status).to eq 200

      user_attributes = json.data.attributes
      expect(user_attributes.email).to eq @user.email
    end

    it "returns an error when the email is not found" do
      post "#{host}/users/forgot_password", {
        user: {
          email: "not-existing-user@mail.com"
        }
      }
      expect(last_response.status).to eq 422
      expect(json.errors.email).to include "doesn't exist"
    end
  end

  context "POST /users/reset_password" do

    before do
      @user = create(:user, id: 10, email: 'existing-user@mail.com', password: 'test_password')
    end

    it "resets the password when the authentication token is valid" do
      post "#{host}/users/forgot_password", {
        user: {
          email: "existing-user@mail.com"
        }
      }

      user = User.first

      post "#{host}/users/reset_password", {
        user: {
          confirmation_token: "#{user.confirmation_token}",
          password: "newpassword"
        }
      }

      expect(last_response.status).to eq 200
      token = authenticate(email: "existing-user@mail.com", password: "newpassword")
      expect(token).to_not be_nil
    end

    it "doesn't reset the password when the authentication token is not valid" do
      post "#{host}/users/forgot_password", {
        user: {
          email: "existing-user@mail.com"
        }
      }

      user = User.first
      token = "fakeconfirmationtoken"

      post "#{host}/users/reset_password", {
        user: {
          confirmation_token: "#{token}",
          password: "newpassword"
        }
      }

      expect(last_response.status).to eq 422
      expect(json.errors.password).to include "couldn't be reset"
    end
  end

  context "PATCH /users" do
    before do
      @edited_user = create(:user, website: "initial.com", biography: "Initial", twitter: "@user")
    end

    context "when unauthenticated" do
      it "returns a 401 with a proper error message" do
        patch "#{host}/users", { id: @edited_user.id, website: "edit.com" }

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
          authenticated_patch "/users", { id: @edited_user.id, website: "edit.com", biography: "Edited", twitter: "@edit" }, @token

          expect(last_response.status).to eq 200

          user_json = json.data.attributes
          expect(user_json.website).to eq "edit.com"
          expect(user_json.biography).to eq "Edited"
          expect(user_json.twitter).to eq "@edit"

          user = @edited_user.reload
          expect(user.website).to eq "edit.com"
          expect(user.biography).to eq "Edited"
          expect(user.twitter).to eq "@edit"
        end

        it "allows updating of only specific parameters" do
          params = {
            id: @edited_user.id,
            website: "edit.com",
            biography: "Edited",
            twitter: "@edit",
            email: "new@mail.com",
            encrypted_password: "bla",
            confirmation_token: "bla",
            remember_token: "bla",
            username: "bla",
            admin: true
          }

          expect_any_instance_of(User).to receive(:update).with({ website: "edit.com", biography: "Edited", twitter: "@edit"}.with_indifferent_access)
          authenticated_patch "/users", params, @token
        end
      end

      context "as another user" do
        before do
          @regular_user = create(:user, admin: false, email: "regular@mail.com", password: "password")
          @token = authenticate(email: "regular@mail.com", password: "password")
        end
        it "returns a 401 with a proper error message" do
          authenticated_patch "#{host}/users", { id: @edited_user.id, website: "edit.com" }, @token

          expect(last_response.status).to eq 401
          expect(json).to be_a_valid_json_api_error.with_id("NOT_AUTHORIZED")
        end
      end
    end
  end

  context "PATCH /users/me" do
    before do
      @edited_user = create(:user, website: "initial.com", biography: "Initial", twitter: "@user")
      @edit_params = { id: @edited_user.id, website: "edit.com", biography: "Edited", twitter: "@edit" }
    end

    context "when unauthenticated" do
      it "returns a 401 with a proper error message" do
        patch '/users', @edit_params

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id("NOT_AUTHORIZED")
      end
    end

    context "when authenticated" do
      before do
        @current_user = create(:user, email: "current@mail.com", password: "password", website: "initial.com", biography: "Initial", twitter: "@user")
        @token = authenticate(email: "current@mail.com", password: "password")
      end

      it "performs the edit" do
        authenticated_patch "/users/me", { website: "edit.com", biography: "Edited", twitter: "@edit" }, @token

        expect(last_response.status).to eq 200

        user_json = json.data.attributes
        expect(user_json.website).to eq "edit.com"
        expect(user_json.biography).to eq "Edited"
        expect(user_json.twitter).to eq "@edit"

        current_user = @current_user.reload
        expect(current_user.website).to eq "edit.com"
        expect(current_user.biography).to eq "Edited"
        expect(current_user.twitter).to eq "@edit"
      end

      it "allows updating of only specific parameters" do
        params = {
          website: "edit.com",
          biography: "Edited",
          twitter: "@edit",
          email: "new@mail.com",
          encrypted_password: "bla",
          confirmation_token: "bla",
          remember_token: "bla",
          username: "bla",
          admin: true
        }

        expect_any_instance_of(User).to receive(:update).with({ website: "edit.com", biography: "Edited", twitter: "@edit"}.with_indifferent_access)
        authenticated_patch "/users/me", params, @token
      end
    end
  end
end
