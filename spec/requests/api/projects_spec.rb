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

  context "POST /projects" do
    it 'creates a project with a user uploaded image' do
      Sidekiq::Testing.inline! do
        file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
        base_64_image = Base64.encode64(open(file) { |io| io.read })

        post "#{host}/projects", {
          data: {
            attributes: {
              title: "Test Project Title",
              description: "Test project description",
              base_64_icon_data: base_64_image
            }
          }
        }

        expect(last_response.status).to eq 200

        project = Project.last

        expect(project.base_64_icon_data).to be_nil
        expect(project.icon.path).to_not be_nil
        # expect photo saved from create action to be identical to our test photo
        project_icon_file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
        base_64_saved_image = Base64.encode64(open(project_icon_file) { |io| io.read })
        expect(base_64_saved_image).to include base_64_image
      end
    end
  end
end
