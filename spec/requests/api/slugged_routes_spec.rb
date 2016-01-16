require "rails_helper"

describe "Slugged Routes API" do

  context "GET /:slug" do

    context "when successful" do
      before do
        @slugged_route = create(:organization).slugged_route
        get "#{host}/#{@slugged_route.slug}"
      end

      it"responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns a SluggedRoute, serialized with SluggedRouteSerializer, with owner included" do
        expect(json).to serialize_object(@slugged_route)
                          .with(SluggedRouteSerializer)
                          .with_includes("owner")
      end
    end

    context "when the slugged_route doesn't exist" do
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
