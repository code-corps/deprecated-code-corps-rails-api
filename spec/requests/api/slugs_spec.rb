require 'rails_helper'

describe "Slugs API" do

  describe "GET /:slug" do
    context "when an organization with specified slug exists" do
      before do
        organization = build(:organization, name: "Test")
        CodeCorps::Scenario::SaveOrganization.new(organization).call
      end

      it "calls the OrganizationsController#show action" do
        expect_any_instance_of(OrganizationsController).to receive(:show).and_call_original
        get "#{host}/test"
      end
    end

    context "when a user wth specified slug exists" do
      before do
        user = build(:user, username: "test")
        CodeCorps::Scenario::SaveUser.new(user).call
      end

      it "calls the UsersController#show action" do
        expect_any_instance_of(UsersController).to receive(:show).and_call_original
        get "#{host}/test"
      end
    end

    context "when neither an organization nor a user exist" do
      it "responds with a 404" do
        get "#{host}/test"
        expect(last_response.status).to eq 404
        expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
      end
    end
  end
end
