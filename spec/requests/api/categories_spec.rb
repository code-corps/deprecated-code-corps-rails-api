require "rails_helper"

describe "Categories API", :json_api do
  context "GET /categories" do
    before do
      @categories = create_list(:category, 10)
    end

    context "when successful" do
      before do
        get "#{host}/categories"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns a list of categories, serialized using CategorySerializer" do
        expect(json).to serialize_collection(@categories).
          with(CategorySerializer)
      end
    end
  end

  describe "GET /categories/:id" do
    let(:category) { create(:category) }

    context "when successful" do
      before do
        get "#{host}/categories/#{category.id}"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns a serialized category" do
        expect(json).to serialize_object(category).
          with(CategorySerializer)
      end
    end
  end

  context "POST /categories" do
    context "when unauthenticated" do
      it "responds with a 401 not authorized" do
        post "#{host}/categories", data: { type: "categories" }
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
            type: "categories",
            attributes: {
              name: "Science"
            }
          }
        }
      end

      def make_request(params)
        authenticated_post "/categories", params, token
      end

      context "as a regular user" do
        it "responds with a 403 forbidden" do
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
            expect(json).to serialize_object(Category.last).
              with(CategorySerializer)
          end
        end

        context "when the attributes are invalid" do
          let(:invalid_attributes) do
            {
              data: {
                attributes: {
                  name: nil
                }
              }
            }
          end

          it "responds with a 422 validation error" do
            authenticated_post "/categories", invalid_attributes, token
            expect(last_response.status).to eq 422
            expect(json).to be_a_valid_json_api_validation_error
          end
        end
      end
    end
  end
end
