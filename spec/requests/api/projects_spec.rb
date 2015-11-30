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
    it 'returns an error if title is left blank' do
      post "#{host}/projects", {
        data: {
          attributes: {
            description: "Test project description"
          }
        }
      }

      expect(last_response.status).to eq 422
      expect(json.errors.title).to eq "can't be blank"
    end

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
        expect(project.title).to eq "Test Project Title"
        expect(project.description).to eq "Test project description"
        # expect icon saved from create action to be identical to our test photor
        project_icon_file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
        base_64_saved_image = Base64.encode64(open(project_icon_file) { |io| io.read })
        expect(base_64_saved_image).to include base_64_image
      end
    end

    it 'creates a project without a user uploaded image' do
      post "#{host}/projects", {
          data: {
            attributes: {
              title: "Test Project Title",
              description: "Test project description",
            }
          }
        }

        expect(last_response.status).to eq 200

        project = Project.last
      
        expect(project.icon.path).to be_nil
        expect(project.title).to eq "Test Project Title"
        expect(project.description).to eq "Test project description"
    end
  end

  context 'PATCH /projects/:id' do

    let(:project) { create(:project) }

    context 'when updating the title' do
      it 'updates a project title' do
        patch "#{host}/projects/#{project.id}", {
          data: {
            attributes: {
              title: "New title"
            }
          }
        }

        project.reload

        expect(project.title).to eq "New title"
      end

      it 'returns an error when with a nil title' do
        patch "#{host}/projects/#{project.id}", {
            data: {
              attributes: {
                title: nil
              }
            }
          }

        expect(last_response.status).to eq 422
        expect(json.errors.title).to eq "can't be blank"
      end
    end

    it 'updates a project description' do
      patch "#{host}/projects/#{project.id}", {
        data: {
          attributes: {
            description: "New description"
          }
        }
      }

      project.reload

      expect(project.description).to eq "New description"
    end

    it 'updates a project icon for a project without an icon' do
      Sidekiq::Testing.inline! do
        file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
        base_64_image = Base64.encode64(open(file) { |io| io.read })

        patch "#{host}/projects/#{project.id}", {
          data: {
            attributes: {
              base_64_icon_data: base_64_image
            }
          }
        }

        project.reload

        expect(project.base_64_icon_data).to be_nil
        expect(project.icon.path).to_not be_nil
        project_icon_file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
        base_64_saved_image = Base64.encode64(open(project_icon_file) { |io| io.read })
        expect(base_64_saved_image).to include base_64_image
      end
    end
  end
end
