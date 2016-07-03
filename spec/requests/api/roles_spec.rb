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
        expect(json).to serialize_collection(@roles).
          with(RoleSerializer).
          with_includes("skills")
      end
    end
  end

  describe "GET /user_roles/:id" do
    let(:user_role) { create(:user_role) }

    context "when successful" do
      before do
        get "#{host}/user_roles/#{user_role.id}"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns a serialized user_role" do
        expect(json).to serialize_object(user_role).
          with(UserRoleSerializer)
      end
    end
  end

  context "POST /roles" do
    context "when unauthenticated" do
      it "responds with a 401 not authorized" do
        post "#{host}/roles", data: { type: "roles" }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
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
              ability: "Backend Development",
              kind: "technology"
            }
          }
        }
      end

      def make_request(params)
        authenticated_post "/roles", params, token
      end

      context "as a regular user" do
        it "responds with a 403 FORBIDDEN" do
          make_request(params)
          expect(last_response.status).to eq 403
          expect(json).to be_a_valid_json_api_error.with_id "FORBIDDEN"
        end
      end

      context "as an admin user" do
        let(:user) { create :user, password: "password", admin: true }
        let(:token) { authenticate email: user.email, password: "password" }

        context "with valid params" do
          it "works" do
            make_request(params)
            expect(last_response.status).to eq 200
            expect(json).to serialize_object(Role.last).
              with(RoleSerializer)
          end
        end

        context "when the attributes are invalid" do
          let(:invalid_attributes) do
            {
              data: {
                attributes: {
                  name: nil,
                  ability: nil,
                  kind: nil
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
