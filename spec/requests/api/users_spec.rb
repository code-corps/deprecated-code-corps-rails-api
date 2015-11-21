require 'rails_helper'

describe "Users API" do

  before(:each) do
    ActionMailer::Base.deliveries = []
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

end