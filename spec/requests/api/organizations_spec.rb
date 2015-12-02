require 'rails_helper'

describe "Organizations API" do


  context 'GET /organizations/:id' do
    before do
      @organization = create(:organization, name: "organization")
      get "#{host}/organizations/#{@organization.id}"
    end

    it "responds with a 200" do
      expect(last_response.status).to eq 200
    end

    it "retrieves the specified organization by id using OrganizationSerializer" do
      expect(json).to serialize_object(Organization.find(@organization.id)).with(OrganizationSerializer)
    end
  end

  context 'GET /organizations/:slug' do
    before do
      @organization = create(:organization, name: "organization")
      get "#{host}/organizations/#{@organization.slug}"
    end

    it "responds with a 200" do
      expect(last_response.status).to eq 200
    end

    it "retrieves the specified organization by slug using OrganizationSerializer" do
      expect(json).to serialize_object(Organization.find(@organization.id)).with(OrganizationSerializer)
    end
  end
end
