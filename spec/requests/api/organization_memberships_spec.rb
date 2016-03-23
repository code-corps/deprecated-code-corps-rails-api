require "rails_helper"

# TODO: A big part of this behavior can be covered by proper policy specs
# We should likely only test the major cases here
# - not found
# - not allowed
# - successful
describe "OrganizationMemberships API" do
  context "GET /organizations/:id/memberships" do
    context "when the organization doesn't exist" do
      it "responds with a 404" do
        get "#{host}/organizations/1/memberships"
        expect(last_response.status).to eq 404
        expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
      end
    end

    context "when successful" do
      let(:organization) { create(:organization) }

      before do
        create_list(:organization_membership, 7, organization: organization, role: :pending)
        create_list(:organization_membership, 12, organization: organization, role: :contributor)
        create_list(:organization_membership, 5, organization: organization, role: :admin)
        create(:organization_membership, organization: organization, role: :owner)
      end

      it "returns the first page of memberships" do
        get "#{host}/organizations/#{organization.id}/memberships"

        expect(last_response.status).to eq 200
        expect(json)
          .to serialize_collection(organization.organization_memberships.page(1).per(10))
          .with(OrganizationMembershipSerializer)
          .with_meta(total_records: 25, total_pages: 3, page_size: 10, current_page: 1)
      end

      it "allows filtering by role" do
        get "#{host}/organizations/#{organization.id}/memberships", role: "pending"
        expect(last_response.status).to eq 200
        expect(json)
          .to serialize_collection(organization.organization_memberships.where(role: :pending))
          .with(OrganizationMembershipSerializer)
          .with_meta(total_records: 7, total_pages: 1, page_size: 10, current_page: 1)
      end

      it "allows specifying the page" do
        get "#{host}/organizations/#{organization.id}/memberships", page: { number: 2 }
        expect(last_response.status).to eq 200
        expect(json)
          .to serialize_collection(organization.organization_memberships.page(2).per(10))
          .with(OrganizationMembershipSerializer)
          .with_meta(total_records: 25, total_pages: 3, page_size: 10, current_page: 2)
      end

      it "allows both page and role" do
        get "#{host}/organizations/#{organization.id}/memberships",
            page: { number: 2 }, role: "contributor"
        expect(last_response.status).to eq 200
        expected_collection = organization
                              .organization_memberships.where(role: :contributor).page(2).per(10)
        expect(json)
          .to serialize_collection(expected_collection)
          .with(OrganizationMembershipSerializer)
          .with_meta(total_records: 12, total_pages: 2, page_size: 10, current_page: 2)
      end
    end
  end

  context "POST /organization_memberships" do
    context "when unauthenticated" do
      it "allows creating a 'pending' membership"

      it "responds with a 401 for any other membership role" do
        %w(contributor admin owner).each do |role|
          post "#{host}/organization_memberships", data: { role: role }
          expect(last_response.status).to eq 401
          expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
        end
      end
    end

    context "when authenticated" do
      pending "contributors cannot create anything"
      pending "pending members cannot create anything"
      pending "'admin' create 'pending' or 'contributor' roles"
      pending "'admin' cannot create 'admin' or 'owner' roles"
      pending "'owner' can create all roles"
      pending "what happens when 'owner' creates an 'owner'?"
    end
  end

  context "PATCH /posts/:id" do
    context "when unauthenticated" do
      it "responds with a proper 401" do
        patch "#{host}/organization_memberships/1"
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      pending "'pending' and 'contributor' members cannot do anything"
      pending "'admin' and 'owner' can approve 'pending' members"
      pending "'admin' and 'owner' can promote 'contributor' to 'admin'"
      pending "what happens when 'owner' promotes another member to an 'owner'?"
    end
  end

  context "DELETE /organization_memberships/:id" do
    context "when unauthenticated" do
      it "responds with a proper 401" do
        delete "#{host}/organization_memberships/1"
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      pending "'pending', 'contributor' and 'admin' members can destroy their own memberships"
      pending "'admin' and 'owner' can destroy other 'pending' and 'contributor' members"
      pending "'owner' can destroy other 'pending', 'contributor' or 'admin' members"
      pending "'onwer' cannot destroy their own membership"
    end
  end
end
