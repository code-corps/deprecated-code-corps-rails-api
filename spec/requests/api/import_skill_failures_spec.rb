require "rails_helper"

describe "ImportSkillFailures API" do
  context "GET /import_skill_failures/" do
    context "when not authenticated" do
      it "responds with a proper message" do
        get "#{host}/import_skill_failures"
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate email: user.email, password: "password" }

      context "when not authorized" do
        let(:user) { create(:user, password: "password") }

        it "responds with a proper message" do
          authenticated_get "/import_skill_failures", nil, token
          expect(last_response.status).to eq 401
          expect(json).to be_a_valid_json_api_error.with_id "ACCESS_DENIED"
        end
      end

      context "when authorized" do
        let(:user) { create(:user, password: "password", admin: true) }

        before { create_list(:import_skill_failure, 5) }

        it "responds with a list of failures" do
          authenticated_get "/import_skill_failures", nil, token
          expect(last_response.status).to eq 200
          expect(json).
            to serialize_collection(ImportSkillFailure.all).
            with(ImportSkillFailureSerializer)
        end
      end
    end
  end
end
