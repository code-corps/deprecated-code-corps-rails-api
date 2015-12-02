describe "organization/user slug routing" do

  context "when an organization with the specified slug exists" do
    before do
      create(:organization, name: "Test")
    end

    it "routes to the organization controller" do
      expect(:get => "#{host}/test").to route_to(subdomain: "api", controller: "organizations", slug: "test", action: "show")
    end
  end

  context "when a user with the specified slug exists" do
    before do
      create(:user, username: "test")
    end

    it "routes to the user controller" do
      expect(:get => "#{host}/test").to route_to(subdomain: "api", controller: "users", slug: "test", action: "show")
    end
  end

  context "when both user and organization with the specified slug exist" do
    before do
      create(:organization, name: "Test")
      create(:user, username: "test")
    end

    it "routes to the organization controller" do
      expect(:get => "#{host}/test").to route_to(subdomain: "api", controller: "organizations", slug: "test", action: "show")
    end
  end
end
