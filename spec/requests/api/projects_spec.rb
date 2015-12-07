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

  context "GET /:slug/:project_slug" do
    before do
      @project = create(:project, owner: create(:organization))
    end

    context "when successful" do
      before do
        get "#{host}/#{@project.owner.member.slug}/#{@project.slug}"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns the specified project" do
        expect(json).to serialize_object(@project).with(ProjectSerializer)
      end
    end

  end

  context "POST /projects" do
    it 'responds with a validation error if title is left blank' do
      post "#{host}/projects", {
        data: {
          attributes: {
            description: "Test project description"
          }
        }
      }

      expect(json).to be_a_valid_json_api_error
      expect(json).to contain_an_error_of_type("VALIDATION_ERROR")
                        .with_message "Title may only contain alphanumeric characters, underscores, or single hyphens, and cannot begin or end with a hyphen or underscore"
    end

    context "when succesful" do
      context "when there's icon data in the request" do
        before do
          file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
          @base_64_image = Base64.encode64(open(file) { |io| io.read })

          attributes = {
            data: {
              attributes: {
                title: "TestProject",
                description: "Test project description",
                base_64_icon_data: @base_64_image
              }
            }
          }

          Sidekiq::Testing.inline! do
            post "#{host}/projects", attributes
          end
        end

        it "creates a project" do
          project = Project.last
          expect(project.title).to eq "TestProject"
          expect(project.description).to eq "Test project description"
        end

        it "stores and assigns the user-uploaded image" do
          project = Project.last

          expect(project.base_64_icon_data).to be_nil
          expect(project.icon.path).to_not be_nil
          project_icon_file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
          base_64_saved_image = Base64.encode64(open(project_icon_file) { |io| io.read })
          expect(base_64_saved_image).to include @base_64_image
        end
      end

      context "when there's no icon data in the request" do
        before do
          attributes = {
            data: {
              attributes: {
                title: "TestProject",
                description: "Test project description",
              }
            }
          }

          Sidekiq::Testing.inline! do
            post "#{host}/projects", attributes
          end
        end

        it "responds with a 200" do
          expect(last_response.status).to eq 200
        end

        it "returns the project serialized with ProjectSerializer" do
          expect(json).to serialize_object(Project.last).with(ProjectSerializer)
        end

        it "creates a project" do
          project = Project.last
          expect(project.title).to eq "TestProject"
          expect(project.description).to eq "Test project description"
        end

        it "stores no image data" do
          project = Project.last

          expect(project.base_64_icon_data).to be_nil
          expect(project.icon.path).to be_nil
        end
      end
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
