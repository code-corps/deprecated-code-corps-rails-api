# == Schema Information
#
# Table name: role_skills
#
#  id         :integer          not null, primary key
#  role_id    :integer
#  skill_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

describe RoleSkillSerializer, type: :serializer do
  context "individual resource representation" do
    let(:resource) { create(:role_skill) }

    let(:serializer) { RoleSkillSerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

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

      it "has a type set to 'role_skills'" do
        expect(subject["type"]).to eq "role_skills"
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should contain a 'role' relationship" do
        expect(subject["role"]).not_to be_nil
        expect(subject["role"]["data"]["type"]).to eq "roles"
        expect(subject["role"]["data"]["id"]).to eq resource.role.id.to_s
      end

      it "should contain a 'skill' relationship" do
        expect(subject["skill"]).not_to be_nil
        expect(subject["skill"]["data"]["type"]).to eq "skills"
        expect(subject["skill"]["data"]["id"]).to eq resource.skill.id.to_s
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

      context "when including 'role'" do
        let(:serialization) do
          ActiveModel::Serializer::Adapter.create(serializer, include: ["role"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "roles" }.length).to eq 1
        end
      end

      context "when including 'skill'" do
        let(:serialization) do
          ActiveModel::Serializer::Adapter.create(serializer, include: ["skill"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "skills" }.length).to eq 1
        end
      end
    end
  end
end
