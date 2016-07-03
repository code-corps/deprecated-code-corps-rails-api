require "rails_helper"

describe "Imports API" do
  feature "cors" do
    it "should be supported for POST" do
      post "#{host}/imports", nil, "HTTP_ORIGIN" => "*"
      expect(last_response).to have_proper_cors_headers

      cors_options("imports", :post)
      expect(last_response).to have_proper_preflight_options_response_headers
    end
  end

  context "POST /imports" do
    context "when unauthenticated" do
      it "should return a 401 with a proper error" do
        post "#{host}/imports", data: { type: "imports" }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate(email: user.email, password: user.password) }

      context "when user is admin" do
        let(:user) { create(:user, :admin) }

        context "with valid data" do
          before do
            params = {
              import: {
                file: fixture_file_upload(
                  Rails.root.join("spec", "sample_data", "import.csv"),
                  "text/plain"
                )
              }
            }
            authenticated_post "/imports", params, token
          end

          it "creates a valid import" do
            expect(Import.last.file_file_name).to eq "import.csv"
          end

          it "responds with a 200" do
            expect(last_response.status).to eq 200
          end
        end
      end

      context "when user is not admin" do
        let(:user) { create(:user) }

        before do
          params = {
            import: {
              file: fixture_file_upload(
                Rails.root.join("spec", "sample_data", "import.csv"),
                "text/plain"
              )
            }
          }
          authenticated_post "/imports", params, token
        end

        it "responds with a 403 FORBIDDEN" do
          expect(last_response.status).to eq 403
          expect(json).to be_a_valid_json_api_error.with_id "FORBIDDEN"
        end
      end
    end
  end
end
