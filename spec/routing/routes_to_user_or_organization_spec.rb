require "rails_helper"
require "code_corps/scenario/save_organization"
require "code_corps/scenario/save_user"

describe "routes to user or organization" do

  context "when an organization with the specified slug exists" do
    before do
      organization = build(:organization, name: "Test")
      CodeCorps::Scenario::SaveOrganization.new(organization).call
    end

    it "routes to the organization controller" do
      expect(:get => "#{host}/test").to route_to(subdomain: "api", controller: "organizations", slug: "test", action: "show")
    end
  end

  context "when a user with the specified slug exists" do
    before do
      user = build(:user, username: "test")
      CodeCorps::Scenario::SaveUser.new(user).call
    end

    it "routes to the organization controller" do
      expect(:get => "#{host}/test").to route_to(subdomain: "api", controller: "users", slug: "test", action: "show")
    end
  end

end