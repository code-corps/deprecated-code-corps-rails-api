require "rails_helper"

describe SluggedRoutePolicy do
  subject { described_class }

  before do
    organization = create(:organization)
    @slugged_route = organization.slugged_route
  end

  permissions :show? do
    it "is permited for anyone" do
      expect(subject).to permit(nil, @slugged_route)
    end
  end
end
