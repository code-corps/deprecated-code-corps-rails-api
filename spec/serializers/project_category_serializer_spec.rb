# == Schema Information
#
# Table name: project_categories
#
#  id         :integer          not null, primary key
#  project_id    :integer
#  category_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

describe ProjectCategorySerializer, type: :serializer do
  context "individual resource representation" do
    let(:resource) { create(:project_category) }

    let(:serializer) { ProjectCategorySerializer.new(resource) }
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

      it "has a type set to 'project_categories'" do
        expect(subject["type"]).to eq "project_categories"
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

      it "should contain a 'category' relationship" do
        expect(subject["category"]).not_to be_nil
        expect(subject["category"]["data"]["type"]).to eq "categories"
        expect(subject["category"]["data"]["id"]).to eq resource.category.id.to_s
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

      context "when including 'category'" do
        let(:serialization) do
          ActiveModel::Serializer::Adapter.create(serializer, include: ["category"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "categories" }.length).to eq 1
        end
      end
    end
  end
end
