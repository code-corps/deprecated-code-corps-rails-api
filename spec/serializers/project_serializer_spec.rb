# == Schema Information
#
# Table name: projects
#
#  id                        :integer          not null, primary key
#  title                     :string           not null
#  description               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  icon_file_name            :string
#  icon_content_type         :string
#  icon_file_size            :integer
#  icon_updated_at           :datetime
#  base64_icon_data          :text
#  slug                      :string           not null
#  organization_id           :integer          not null
#  aasm_state                :string
#  long_description_body     :text
#  long_description_markdown :text
#  open_posts_count          :integer          default(0), not null
#  closed_posts_count        :integer          default(0), not null
#

require "rails_helper"

describe ProjectSerializer, type: :serializer do
  context "individual resource representation" do
    let(:resource) do
      project = create(:project)
      create_list(:project_category, 10, project: project)
      create_list(:project_role, 10, project: project)
      create_list(:project_skill, 10, project: project)
      create_list(:github_repository, 10, project: project)
      project
    end

    let(:serializer) { ProjectSerializer.new(resource) }
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

      it "has a type set to 'projects'" do
        expect(subject["type"]).to eq "projects"
      end
    end

    context "attributes" do
      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'title'" do
        expect(subject["title"]).to_not be_nil
        expect(subject["title"]).to eql resource.title
      end

      it "has a 'description'" do
        expect(subject["description"]).to_not be_nil
        expect(subject["description"]).to eql resource.description
      end

      it "has a 'slug'" do
        expect(subject["slug"]).to_not be_nil
        expect(subject["slug"]).to eql resource.slug
      end

      it "has a 'icon_thumb_url'" do
        expect(subject["icon_thumb_url"]).to_not be_nil
        expect(subject["icon_thumb_url"]).to eql resource.icon.url(:thumb)
      end

      it "has a 'icon_large_url'" do
        expect(subject["icon_large_url"]).to_not be_nil
        expect(subject["icon_large_url"]).to eql resource.icon.url(:large)
      end

      it "has a 'long_description_body'" do
        expect(subject["long_description_body"]).to_not be_nil
        expect(subject["long_description_body"]).to eql resource.long_description_body
      end

      it "has a 'long_description_markdown'" do
        expect(subject["long_description_markdown"]).to_not be_nil
        expect(subject["long_description_markdown"]).to eql resource.long_description_markdown
      end

      it "has an 'closed_posts_count'" do
        expect(subject["closed_posts_count"]).to_not be_nil
        expect(subject["closed_posts_count"]).to eql resource.closed_posts_count
      end

      it "has an 'open_posts_count'" do
        expect(subject["open_posts_count"]).to_not be_nil
        expect(subject["open_posts_count"]).to eql resource.open_posts_count
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should have a 'categories' relationship" do
        expect(subject["categories"]).not_to be_nil
        expect(subject["categories"]["data"].length).to eq 10
        expect(subject["categories"]["data"].all? { |r| r["type"] == "categories" }).to be true
      end

      it "should have a 'roles' relationship" do
        expect(subject["roles"]).not_to be_nil
        expect(subject["roles"]["data"].length).to eq 10
        expect(subject["roles"]["data"].all? { |r| r["type"] == "roles" }).to be true
      end

      it "should have a 'github_repositories' relationship" do
        expect(subject["github_repositories"]).not_to be_nil
        expect(subject["github_repositories"]["data"].length).to eq 10
        expect(subject["github_repositories"]["data"].all? { |r| r["type"] == "github_repositories" }).to be true
      end

      it "should have a 'skills' relationship" do
        expect(subject["skills"]).not_to be_nil
        expect(subject["skills"]["data"].length).to eq 10
        expect(subject["skills"]["data"].all? { |r| r["type"] == "skills" }).to be true
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
    end

    context "when including categories" do
      let(:serialization) do
        ActiveModelSerializers::Adapter.create(serializer, include: ["categories"])
      end

      subject do
        JSON.parse(serialization.to_json)["included"]
      end

      it "should contain the project's categories" do
        expect(subject).not_to be_nil
        expect(subject.select { |i| i["type"] == "categories" }.length).to eq 10
      end
    end

    context "when including roles" do
      let(:serialization) do
        ActiveModelSerializers::Adapter.create(serializer, include: ["roles"])
      end

      subject do
        JSON.parse(serialization.to_json)["included"]
      end

      it "should contain the project's roles" do
        expect(subject).not_to be_nil
        expect(subject.select { |i| i["type"] == "roles" }.length).to eq 10
      end
    end

    context "when including github_repositories" do
      let(:serialization) do
        ActiveModelSerializers::Adapter.create(serializer, include: ["github_repositories"])
      end

      subject do
        JSON.parse(serialization.to_json)["included"]
      end

      it "should contain the project's github_repositories" do
        expect(subject).not_to be_nil
        expect(subject.select { |i| i["type"] == "github_repositories" }.length).to eq 10
      end
    end

    context "when including skills" do
      let(:serialization) do
        ActiveModelSerializers::Adapter.create(serializer, include: ["skills"])
      end

      subject do
        JSON.parse(serialization.to_json)["included"]
      end

      it "should contain the project's skills" do
        expect(subject).not_to be_nil
        expect(subject.select { |i| i["type"] == "skills" }.length).to eq 10
      end
    end
  end
end
