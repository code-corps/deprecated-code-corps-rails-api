# == Schema Information
#
# Table name: project_skills
#
#  id         :integer          not null, primary key
#  project_id :integer
#  skill_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

describe ProjectSkillSerializer, type: :serializer do
  context "individual resource representation" do
    let(:resource) { create(:project_skill) }

    let(:serializer) { ProjectSkillSerializer.new(resource) }
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

      it "has a type set to 'project_skills'" do
        expect(subject["type"]).to eq "project_skills"
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should contain a 'project' relationship" do
        expect(subject["project"]).not_to be_nil
        expect(subject["project"]["data"]["type"]).to eq "projects"
        expect(subject["project"]["data"]["id"]).to eq resource.project.id.to_s
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

      context "when including 'project'" do
        let(:serialization) do
          ActiveModelSerializers::Adapter.create(serializer, include: ["project"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "projects" }.length).to eq 1
        end
      end

      context "when including 'skill'" do
        let(:serialization) do
          ActiveModelSerializers::Adapter.create(serializer, include: ["skill"])
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
