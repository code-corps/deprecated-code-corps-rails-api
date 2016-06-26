require "rails_helper"

describe SluggedRoutePolicy do
  subject { described_class }

  let(:organization) { build_stubbed(:organization) }

  permissions :show? do
    it "is permited for anyone" do
      expect(subject).to permit(nil, organization.slugged_route)
    end
  end
end
