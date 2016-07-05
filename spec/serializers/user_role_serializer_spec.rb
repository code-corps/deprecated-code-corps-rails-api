# == Schema Information
#
# Table name: user_roles
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  role_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

describe UserRoleSerializer, type: :serializer do
  context "individual resource representation" do
    let(:resource) { create(:user_role) }

    let(:serializer) { UserRoleSerializer.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "doesn't have an attributes object" do
        expect(subject["attributes"]).to be_nil
      end

      it "has a relationships object" do
        expect(subject["relationships"]).not_to be_nil
      end

      it "has an id" do
        expect(subject["id"]).not_to be_nil
      end

      it "has a type set to 'user_roles'" do
        expect(subject["type"]).to eq "user_roles"
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should contain a 'user' relationship" do
        expect(subject["user"]).not_to be_nil
        expect(subject["user"]["data"]["type"]).to eq "users"
        expect(subject["user"]["data"]["id"]).to eq resource.user.id.to_s
      end

      it "should contain a 'role' relationship" do
        expect(subject["role"]).not_to be_nil
        expect(subject["role"]["data"]["type"]).to eq "roles"
        expect(subject["role"]["data"]["id"]).to eq resource.role.id.to_s
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

      context "when including 'user'" do
        let(:serialization) do
          ActiveModelSerializers::Adapter.create(serializer, include: ["user"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "users" }.length).to eq 1
        end
      end

      context "when including 'role'" do
        let(:serialization) do
          ActiveModelSerializers::Adapter.create(serializer, include: ["role"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "roles" }.length).to eq 1
        end
      end
    end
  end
end
