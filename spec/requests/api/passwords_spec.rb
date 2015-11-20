require 'rails_helper'

describe "passwords API" do

  describe "POST /passwords/send_email" do
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

	describe "POST /passwords/reset" do
		before do
      @user = create(:user, id: 10, email: 'existing-user@mail.com', password: 'test_password')
    end

    it "resets the password when the authentication token is valid" do
    	post "#{host}/passwords", {
    		user: {
    			email: "existing-user@mail.com"
    		}
    	}

    	user = User.first

    	put "#{host}/passwords/#{user.confirmation_token}", {
    		password: "newpassword"
    	}

    	expect(last_response.status).to eq 200
      token = authenticate(email: "existing-user@mail.com", password: "newpassword")
      expect(token).to_not be_nil
    end

    it "doesn't reset the password when the authentication token is not valid" do
    	post "#{host}/passwords", {
    		user: {
    			email: "existing-user@mail.com"
    		}
    	}

    	user = User.first
    	token = "fakeconfirmationtoken"

    	put "#{host}/passwords/#{token}", {
    		password: "newpassword"
    	}

    	expect(last_response.status).to eq 422
      expect(json.errors.password).to include "couldn't be reset"
    end
	end
end