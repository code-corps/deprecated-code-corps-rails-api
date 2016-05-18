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
        expect(json).to serialize_collection(@roles)
                          .with(RoleSerializer)
                          .with_includes("skills")
      end
    end

  end
end
