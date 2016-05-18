require "rails_helper"

describe "Roles API" do
  context "GET /roles" do
    before do
      @roles = create_list(:role, 10)
    end

    context "when successful" do
      before do
        get "#{host}/roles"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns a list of roles, serialized using RoleSerializer, with skill includes" do
        expect(json).to serialize_collection(@roles)
                          .with(RoleSerializer)
                          .with_includes("skills")
      end
    end
  end

  context "POST /roles" do
    context "when unauthenticated" do
      it "responds with a 401 access denied" do
        post "#{host}/roles", data: { type: "roles" }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "ACCESS_DENIED"
      end
    end

    context "when authenticated" do
      let(:user) { create :user, password: "password" }
      let(:token) { authenticate email: user.email, password: "password" }

      let(:params) do
        {
          data: {
            type: "roles",
            attributes: {
              name: "Backend Developer",
              ability: "Backend Development"
            }
          }
        }
      end

      def make_request(params)
        authenticated_post "/roles", params, token
      end

      context "as a regular user" do
        it "responds with a 401 access denied" do
          make_request(params)
          expect(last_response.status).to eq 401
          expect(json).to be_a_valid_json_api_error.with_id "ACCESS_DENIED"
        end
      end

      context "as an admin user" do
        let(:user) { create :user, password: "password", admin: true }
        let(:token) { authenticate email: user.email, password: "password" }

        context "with valid params" do
          it "works" do
            make_request(params)
            expect(last_response.status).to eq 200
            expect(json).to serialize_object(Role.last)
              .with(RoleSerializer)
          end
        end

        context "when the attributes are invalid" do
          let(:invalid_attributes) do
            {
              data: {
                attributes: {
                  name: nil,
                  ability: nil
                }
              }
            }
          end

          it "responds with a 422 validation error" do
            authenticated_post "/roles", invalid_attributes, token
            expect(last_response.status).to eq 422
            expect(json).to be_a_valid_json_api_validation_error
          end
        end
      end
    end
  end
end
