require "rails_helper"
require "code_corps/scenario/save_user"

module CodeCorps
  module Scenario
    describe SaveUser do
      let(:user) { User.new(username: "code-corps", email: "josh@codecorps.org", password: "password") }

      context "when there is a slug conflict" do
        it "does not save the user or slug route" do
          organization = create(:organization, name: "Code Corps")
          SlugRoute.create(owner: organization, slug: organization.slug)

          expect {
            CodeCorps::Scenario::SaveUser.new(user).call
          }.to raise_error(ActiveRecord::RecordInvalid)

          expect(User.last).to be_nil
          expect(SlugRoute.last.owner).to eq organization
        end
      end

      context "when there is no slug conflict" do
        it "saves the user and the slug route" do
          result = CodeCorps::Scenario::SaveUser.new(user).call

          expect(result).to eq user
          expect(User.last).to eq user
          expect(SlugRoute.last.owner).to eq user
        end
      end
    end
  end
end