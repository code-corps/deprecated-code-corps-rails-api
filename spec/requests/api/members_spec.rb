require "rails_helper"

describe "Members API" do

  context "GET /:slug" do

    context "when successful" do
      before do
        @member = create(:organization).member
        get "#{host}/#{@member.slug}"
      end

      it"responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns a member, serialized with MemberSerializer, with model included" do
        expect(json).to serialize_object(@member)
                          .with(MemberSerializer)
                          .with_includes("model")
      end
    end

    context "when the member doesn't exist" do
      before do
        get "#{host}/random_slug"
      end

      it "responds with a 404" do
        expect(last_response.status).to eq 404
      end

      it "returns a proper error response" do
        expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
      end

    end

  end
end
