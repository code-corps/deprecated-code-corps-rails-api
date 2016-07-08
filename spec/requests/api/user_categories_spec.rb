require "rails_helper"

describe "UserCategories API", :json_api do
  describe "GET /user_categories/:id" do
    let(:user_category) { create(:user_category) }

    context "when successful" do
      before do
        get "#{host}/user_categories/#{user_category.id}"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns a serialized user_category" do
        expect(json).to serialize_object(user_category).
          with(UserCategorySerializer)
      end
    end
  end

  describe "POST /user_categories" do
    context "when unauthenticated" do
      it "responds with a 401" do
        post "#{host}/user_categories", data: {}
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

      before do
        @user = create(:user, email: "josh@coderly.com", password: "password")
        @category = create(:category)
      end

      context "when creation is succesful" do
        before do
          expect_any_instance_of(Analytics).to receive(:track_added_user_category)

          authenticated_post "/user_categories", { data: { relationships: {
            category: { data: { type: "categories", id: @category.id } }
          } } }, token
        end

        it "responds with the created user_category" do
          expect(last_response.status).to eq 200
        end

        it "sets user to current user" do
          expect(json.data.relationships.user.data.id).to eq @user.id.to_s
          expect(UserCategory.last.user).to eq @user
        end

        it "sets category to provided category" do
          expect(json.data.relationships.category.data.id).to eq @category.id.to_s
          expect(UserCategory.last.category).to eq @category
        end

        it "includes user in the response" do
          expect(json.included).not_to be_nil

          included_users = json.included.select { |i| i.type == "users" }
          expect(included_users.count).to eq 1
        end

        it "includes category in the response" do
          expect(json.included).not_to be_nil

          included_users = json.included.select { |i| i.type == "categories" }
          expect(included_users.count).to eq 1
        end
      end

      context "when there's a user_category with that pair of user_id and category_id already" do
        before do
          create(:user_category, user: @user, category: @category)
          authenticated_post "/user_categories", { data: { relationships: {
            category: { data: { type: "categories", id: @category.id } }
          } } }, token
        end

        it "fails with a validation error" do
          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
        end
      end

      context "when there's no category with the specified id" do
        it "fails with a validation error" do
          authenticated_post "/user_categories", { data: { relationships: {
            category: { data: { type: "categories", id: 55 } }
          } } }, token

          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
        end
      end

      it "requires a category to be specified" do
        authenticated_post "/user_categories", { data: { relationships: {} } }, token
        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
      end
    end
  end

  describe "DELETE /user_categories/:id" do
    context "when unauthenticated" do
      it "responds with a 401" do
        delete "#{host}/user_categories/1"

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
        create(:user_category, id: 1)

        authenticated_delete "/user_categories/1", {}, token

        expect(last_response.status).to eq 403
        expect(json).to be_a_valid_json_api_error.with_id "FORBIDDEN"
        expect(UserCategory.count).to eq 1
      end

      context "when deletion is successful" do
        before do
          user_category = create(:user_category, id: 1, user: @user)
          expect_any_instance_of(Analytics).to receive(:track_removed_user_category).
            with(user_category)
          authenticated_delete "/user_categories/1", {}, token
        end

        it "responds with a 204" do
          expect(last_response.status).to eq 204
        end

        it "deletes the user_category" do
          expect(UserCategory.count).to eq 0
        end

        it "leaves user and category untouched" do
          expect(User.count).to eq 1
          expect(Category.count).to eq 1
        end
      end
    end
  end
end
