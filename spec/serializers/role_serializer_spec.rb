# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string           not null
#  ability    :string           not null
#  kind       :string           not null
#

require "rails_helper"

describe RoleSerializer, type: :serializer do
  context "individual resource representation" do
    let(:resource) do
      role = create(:role, kind: "technology")
      create_list(:role_skill, 10, role: role)
      role
    end

    let(:serializer) { RoleSerializer.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "has an attributes object" do
        expect(subject["attributes"]).not_to be_nil
      end

      it "has a relationships object" do
        expect(subject["relationships"]).not_to be_nil
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

      it "has a 'kind'" do
        expect(subject["kind"]).to eql resource.kind
        expect(subject["kind"]).to_not be_nil
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "has a skills relationship" do
        expect(subject["skills"]).not_to be_nil
        expect(subject["skills"]["data"].length).to eq 10
      end
    end

    context "included" do
      context "when not including anything" do
        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should be empty" do
          expect(subject).to be_nil
        end
      end

      context "when including skills" do
        let(:serialization) do
          ActiveModelSerializers::Adapter.create(serializer, include: ["skills"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should contain the role's skills" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "skills" }.length).to eq 10
        end
      end
    end
  end
end
