require "rails_helper"

describe "UserRoles API" do
  describe "POST /user_roles" do
    context "when unauthenticated" do
      it "responds with a 401" do
        post "#{host}/user_roles", data: {}
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

      before do
        @user = create(:user, email: "josh@coderly.com", password: "password")
        @role = create(:role)
      end

      context "when creation is succesful" do
        before do
          expect_any_instance_of(Analytics).to receive(:track_added_user_role)

          authenticated_post "/user_roles", { data: { relationships: {
            role: { data: { type: "roles", id: @role.id } }
          } } }, token
        end

        it "responds with the created user_role" do
          expect(last_response.status).to eq 200
        end

        it "sets user to current user" do
          expect(json.data.relationships.user.data.id).to eq @user.id.to_s
          expect(UserRole.last.user).to eq @user
        end

        it "sets role to provided role" do
          expect(json.data.relationships.role.data.id).to eq @role.id.to_s
          expect(UserRole.last.role).to eq @role
        end

        it "includes user in the response" do
          expect(json.included).not_to be_nil

          included_users = json.included.select { |i| i.type == "users" }
          expect(included_users.count).to eq 1
        end

        it "includes role in the response" do
          expect(json.included).not_to be_nil

          included_users = json.included.select { |i| i.type == "roles" }
          expect(included_users.count).to eq 1
        end
      end

      context "when there's a user_role with that pair of user_id and role_id already" do
        before do
          create(:user_role, user: @user, role: @role)
          authenticated_post "/user_roles", { data: { relationships: {
            role: { data: { type: "roles", id: @role.id } }
          } } }, token
        end

        it "fails with a validation error" do
          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
        end
      end

      context "when there's no role with the specified id" do
        it "fails with a validation error" do
          authenticated_post "/user_roles", { data: { relationships: {
            role: { data: { type: "roles", id: 55 } }
          } } }, token

          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
        end
      end

      it "requires a role to be specified" do
        authenticated_post "/user_roles", { data: { relationships: {} } }, token
        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
      end
    end
  end

  describe "DELETE /user_roles/:id" do
    context "when unauthenticated" do
      it "responds with a 401" do
        delete "#{host}/user_roles/1"

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

      before do
        @user = create(:user, email: "josh@coderly.com", password: "password")
      end

      it "requires the user to be the current user" do
        create(:user_role, id: 1)

        authenticated_delete "/user_roles/1", {}, token

        expect(last_response.status).to eq 403
        expect(json).to be_a_valid_json_api_error.with_id "FORBIDDEN"
        expect(UserRole.count).to eq 1
      end

      context "when deletion is successful" do
        before do
          user_role = create(:user_role, id: 1, user: @user)
          expect_any_instance_of(Analytics).to receive(:track_removed_user_role).
            with(user_role)
          authenticated_delete "/user_roles/1", {}, token
        end

        it "responds with a 204" do
          expect(last_response.status).to eq 204
        end

        it "deletes the user_role" do
          expect(UserRole.count).to eq 0
        end

        it "leaves user and role untouched" do
          expect(User.count).to eq 1
          expect(Role.count).to eq 1
        end
      end
    end
  end
end
