require "rails_helper"

describe "Projects API" do

  context "GET /projects" do
    before do
      create_list(:project, 10)
    end

    it "returns a list of projects" do
      get "#{host}/projects"

      expect(last_response.status).to eq 200
      expect(json.data.length).to eq 10
      expect(json.data.all? { |item| item.type == "projects" }).to be true
    end
  end

  context "GET /projects/:id" do
    before do
      create(:project, id: 1, title: "Project", description: "Description")
    end

    it "returns the specified project" do
      get "#{host}/projects/1", {}
      expect(last_response.status).to eq 200

      expect(json.data.id).to eq "1"
      expect(json.data.type).to eq "projects"

      attributes = json.data.attributes
      expect(attributes.title).to eq "Project"
      expect(attributes.description).to eq "Description"
    end
  end
end
