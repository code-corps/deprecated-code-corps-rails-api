require "rails_helper"

describe "Members API" do

  context "GET /:slug" do
    before do
      @member = create(:organization).member
    end

    context "when successful" do
      before do
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

  end
end
