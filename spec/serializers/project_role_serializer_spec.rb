require "rails_helper"

describe ProjectRoleSerializer, type: :serializer do
  context "individual resource representation" do
    let(:resource) { create(:project_role) }

    let(:serializer) { ProjectRoleSerializer.new(resource) }
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

      it "has a type set to 'project_roles'" do
        expect(subject["type"]).to eq "project_roles"
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

      context "when including 'project'" do
        let(:serialization) do
          ActiveModel::Serializer::Adapter.create(serializer, include: ["project"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "projects" }.length).to eq 1
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
    end
  end
end
