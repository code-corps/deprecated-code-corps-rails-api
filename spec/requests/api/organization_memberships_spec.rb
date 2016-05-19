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
        expect(json).
          to serialize_collection(organization.organization_memberships.page(1).per(10)).
          with(OrganizationMembershipSerializer).
          with_meta(total_records: 25, total_pages: 3, page_size: 10, current_page: 1)
      end

      it "allows filtering by role" do
        get "#{host}/organizations/#{organization.id}/memberships", role: "pending"
        expect(last_response.status).to eq 200
        expect(json).
          to serialize_collection(organization.organization_memberships.where(role: :pending)).
          with(OrganizationMembershipSerializer).
          with_meta(total_records: 7, total_pages: 1, page_size: 10, current_page: 1)
      end

      it "allows specifying the page" do
        get "#{host}/organizations/#{organization.id}/memberships", page: { number: 2 }
        expect(last_response.status).to eq 200
        expect(json).
          to serialize_collection(organization.organization_memberships.page(2).per(10)).
          with(OrganizationMembershipSerializer).
          with_meta(total_records: 25, total_pages: 3, page_size: 10, current_page: 2)
      end

      it "allows both page and role" do
        get "#{host}/organizations/#{organization.id}/memberships",
            page: { number: 2 }, role: "contributor"
        expect(last_response.status).to eq 200
        expected_collection = organization.organization_memberships.
                              where(role: :contributor).page(2).per(10)
        expect(json).
          to serialize_collection(expected_collection).
          with(OrganizationMembershipSerializer).
          with_meta(total_records: 12, total_pages: 2, page_size: 10, current_page: 2)
      end
    end
  end

  context "POST /organization_memberships" do
    let(:organization) { create(:organization) }
    let(:applicant) { create(:user, password: "password") }

    context "when unauthenticated" do
      it "responds with a 401 NOT_AUTHORIZED" do
        post "#{host}/organization_memberships", data: {
          type: "organization_memberships",
          attributes: { role: :pending },
          relationships: {
            member: { data: { id: applicant.id, type: "users" } },
            organization: { data: { id: organization.id, type: "organizations" } }
          }
        }

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate email: applicant.email, password: "password" }

      context "when unauthorized" do
        it "respond with 401 ACCESS_DENIED" do
          authenticated_post "/organization_memberships", {
            data: {
              type: "organization_memberships",
              attributes: { role: :contributor },
              relationships: {
                member: { data: { id: applicant.id, type: "users" } },
                organization: { data: { id: organization.id, type: "organizations" } }
              }
            }
          }, token

          expect(last_response.status).to eq 401
          expect(json).to be_a_valid_json_api_error.with_id "ACCESS_DENIED"
        end
      end

      context "when authorized" do
        it "creates an organization_membership" do
          authenticated_post "/organization_memberships", {
            data: {
              type: "organization_memberships",
              attributes: { role: :pending },
              relationships: {
                member: { data: { id: applicant.id, type: "users" } },
                organization: { data: { id: organization.id, type: "organizations" } }
              }
            }
          }, token

          expect(last_response.status).to eq 200
          expect(json).
            to serialize_object(OrganizationMembership.last).
            with(OrganizationMembershipSerializer)
        end
      end
    end
  end

  context "PATCH /organization_memberships/:id" do
    let(:organization) { create(:organization) }
    let(:applicant) { create(:user, password: "password") }
    let(:admin) { create(:user, password: "password") }
    let(:membership) do
      create(
        :organization_membership,
        role: :pending, member: applicant, organization: organization)
    end

    context "when unauthenticated" do
      it "responds with a 401 NOT_AUTHORIZED" do
        patch "#{host}/organization_memberships/1"
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      context "when unauthorized" do
        it "respond with 401 ACCESS_DENIED" do
          token = authenticate(email: applicant.email, password: "password")

          authenticated_patch "/organization_memberships/#{membership.id}", {
            data: {
              type: "organization_memberships",
              attributes: { role: :contributor }
            }
          }, token

          expect(last_response.status).to eq 401
          expect(json).to be_a_valid_json_api_error.with_id "ACCESS_DENIED"
        end
      end

      context "when authorized" do
        it "updates an organization_membership" do
          create(:organization_membership, role: :admin, member: admin, organization: organization)

          token = authenticate(email: admin.email, password: "password")

          authenticated_patch "/organization_memberships/#{membership.id}", {
            data: {
              type: "organization_memberships",
              attributes: { role: :contributor }
            }
          }, token

          expect(last_response.status).to eq 200
          expect(json).
            to serialize_object(membership.reload).
            with(OrganizationMembershipSerializer)
        end
      end
    end
  end

  context "DELETE /organization_memberships/:id" do
    let(:applicant) { create(:user, password: "password") }
    let(:user) { create(:user, password: "password") }
    let(:membership) { create(:organization_membership, role: :pending, member: applicant) }

    context "when unauthenticated" do
      it "responds with a 401 NOT_AUTHORIZED" do
        delete "#{host}/organization_memberships/#{membership.id}", {}
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      context "when non-existant" do
        it "responds with a 404" do
          token = authenticate(email: user.email, password: "password")

          authenticated_delete "/organization_memberships/wrong_id", {}, token

          expect(last_response.status).to eq 404
          expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
        end
      end

      context "when unauthorized" do
        it "responds with 401 ACCESS_DENIED" do
          token = authenticate(email: user.email, password: "password")

          authenticated_delete "/organization_memberships/#{membership.id}", {}, token

          expect(last_response.status).to eq 401
          expect(json).to be_a_valid_json_api_error.with_id "ACCESS_DENIED"
        end
      end

      context "when authorized" do
        it "destroys an organization_membership" do
          token = authenticate(email: applicant.email, password: "password")

          authenticated_delete "/organization_memberships/#{membership.id}", {}, token

          expect(last_response.status).to eq 204
          expect(applicant.organization_memberships.count).to eq 0
        end
      end
    end
  end
end
