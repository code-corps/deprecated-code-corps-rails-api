require "rails_helper"

describe "Previews API", :json_api do
  feature "cors" do
    it "should be supported for POST" do
      post "#{host}/previews", nil, "HTTP_ORIGIN" => "*"
      expect(last_response).to have_proper_cors_headers

      cors_options("previews", :post)
      expect(last_response).to have_proper_preflight_options_response_headers
    end

    it "should be supported for PATCH" do
      post "#{host}/previews", nil, "HTTP_ORIGIN" => "*"
      expect(last_response).to have_proper_cors_headers

      cors_options("previews", :patch)
      expect(last_response).to have_proper_preflight_options_response_headers
    end
  end

  context "POST /previews" do
    context "when unauthenticated" do
      it "responds with a proper 401" do
        post "#{host}/previews", data: { type: "previews" }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:user) { create :user, password: "password" }
      let(:token) { authenticate email: user.email, password: "password" }

      let(:mentioned_1) { create(:user) }
      let(:mentioned_2) { create(:user) }

      def make_request(params)
        authenticated_post "/previews", params, token
      end

      let(:params) do
        {
          data: {
            type: "previews",
            attributes: {
              markdown: "@#{mentioned_1.username} @#{mentioned_2.username}"
            }
          }
        }
      end

      context "when the attributes are valid" do
        it "creates a published preview" do
          make_request params

          preview = Preview.last

          # response is correct
          expect(json).to serialize_object(preview).with(PreviewSerializer)

          # attributes are properly set
          expect(preview.body).to eq "<p>@#{mentioned_1.username} @#{mentioned_2.username}</p>"
          expect(preview.markdown).to eq "@#{mentioned_1.username} @#{mentioned_2.username}"

          # relationships are properly set
          expect(preview.user_id).to eq user.id

          # a mention was generated for each mentioned user
          expect(PreviewUserMention.count).to eq 2
        end
      end

      context "when the attributes are invalid" do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: "", markdown: ""
              }
            }
          }
        end

        it "responds with a 422 validation error" do
          make_request invalid_attributes
          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_validation_error
        end
      end
    end
  end
end
