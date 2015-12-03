require "rails_helper"
require "code_corps/scenario/save_organization"

module CodeCorps
  module Scenario
    describe SaveOrganization do
      context "when there is a slug conflict" do
        it "does not save the organization or slug route" do
          user = create(:user, username: "code-corps")
          SlugRoute.create(owner: user, slug: user.username)

          organization = Organization.new(name: "Code Corps")

          expect {
            CodeCorps::Scenario::SaveOrganization.new(organization).call
          }.to raise_error(ActiveRecord::RecordInvalid)

          expect(Organization.last).to be_nil
          expect(SlugRoute.last.owner).to eq user
        end
      end

      context "when there is no slug conflict" do
        it "saves the organization and the slug route" do
          organization = Organization.new(name: "Code Corps")

          result = CodeCorps::Scenario::SaveOrganization.new(organization).call

          expect(result).to eq organization
          expect(Organization.last).to eq organization
          expect(SlugRoute.last.owner).to eq organization
        end
      end
    end
  end
end