require 'rails_helper'
require "code_corps/scenario/save_organization"

describe "Organizations API" do

  context 'GET /:slug' do
    before do
      @organization = create(:organization, name: "Code Corps")
      CodeCorps::Scenario::SaveOrganization.new(@organization).call
      get "#{host}/#{@organization.slug}"
    end

    it "responds with a 200" do
      expect(last_response.status).to eq 200
    end

    it "retrieves the specified organization by id using OrganizationSerializer" do
      expect(json).to serialize_object(Organization.find(@organization.id)).with(OrganizationSerializer)
      expect(json.data.id).to eq @organization.id.to_s
    end
  end

  context 'GET /organizations/:id' do
    before do
      @organization = create(:organization, name: "Code Corps")
      get "#{host}/organizations/#{@organization.id}"
    end

    it "responds with a 200" do
      expect(last_response.status).to eq 200
    end

    it "retrieves the specified organization by id using OrganizationSerializer" do
      expect(json).to serialize_object(Organization.find(@organization.id)).with(OrganizationSerializer)
    end
  end

end
