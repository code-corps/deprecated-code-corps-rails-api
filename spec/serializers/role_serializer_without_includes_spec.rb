require "rails_helper"

describe RoleSerializerWithoutIncludes, :type => :serializer do

  context "individual resource representation" do
    let(:resource) {
      role = create(:role)
      create_list(:role_skill, 10, role: role)
      role
    }

    let(:serializer) { RoleSerializerWithoutIncludes.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "has an attributes object" do
        expect(subject["attributes"]).not_to be_nil
      end

      it "does not have a relationships object" do
        expect(subject["relationships"]).to be_nil
      end

      it "has an id" do
        expect(subject["id"]).not_to be_nil
      end

      it "has a type set to 'roles'" do
        expect(subject["type"]).to eq "roles"
      end
    end

    context "attributes" do
      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'name'" do
        expect(subject["name"]).to eql resource.name
        expect(subject["name"]).to_not be_nil
      end

      it "has an 'ability'" do
        expect(subject["ability"]).to eql resource.ability
        expect(subject["ability"]).to_not be_nil
      end
    end
  end
end
