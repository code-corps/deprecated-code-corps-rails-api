require "rails_helper"
require "code_corps/scenario/save_organization"
require "code_corps/scenario/save_user"

describe "organization/user slug routing" do

  context "when an organization with the specified slug exists" do
    before do
      organization = create(:organization, name: "Test")
      CodeCorps::Scenario::SaveOrganization.new(organization).call
    end

    xit "routes to the organization controller" do
      expect(:get => "#{host}/test").to route_to(subdomain: "api", controller: "organizations", slug: "test", action: "show")
    end
  end

  context "when a user with the specified slug exists" do
    before do
      user = create(:user, username: "Test")
      CodeCorps::Scenario::SaveUser.new(user).call
    end

    xit "routes to the user controller" do
      expect(:get => "#{host}/test").to route_to(subdomain: "api", controller: "users", slug: "test", action: "show")
    end
  end

end
