require "rails_helper"

describe "Projects API" do

  context "GET /projects" do
    before do
      @projects = create_list(:project, 10)
    end

    context "when successful" do
      before do
        get "#{host}/projects"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns a list of projects, serialized with ProjectSerializer, with nothing included" do
        expect(json).to serialize_collection(@projects).with(ProjectSerializer)
      end
    end

  end

  context "GET /:slug/projects" do
    before do
      @member = create(:organization).member
      @projects = create_list(:project, 3, owner: @member.model)
      create_list(:project, 2, owner: create(:organization))
    end

    context "when successful" do
      before do
        get "#{host}/#{@member.slug}/projects"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns a list of projects for the specified member, serialized with ProjectSerializer" do
        expect(json).to serialize_collection(@projects).with(ProjectSerializer)
      end
    end
  end

  context "GET /:slug/:project_slug" do
    before do
      @project = create(:project, owner: create(:organization))
      github_repositories = create_list(:github_repository, 10, project: @project)
    end

    context "when successful" do
      before do
        get "#{host}/#{@project.owner.member.slug}/#{@project.slug}"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns the specified project" do
        expect(json).to serialize_object(@project).with(ProjectSerializer).with_includes(:github_repositories)
      end
    end

    context "when there's no owner" do
      before do
        get "#{host}/slug_1/slug_2"
      end

      it "responds with a 404" do
        expect(last_response.status).to eq 404
      end

      it "returns an error response" do
        expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
      end
    end

    context "when there's no project" do
      before do
        member = create(:organization).member
        get "#{host}/#{member.slug}/slug_2"
      end

      it "responds with a 404" do
        expect(last_response.status).to eq 404
      end

      it "returns an error response" do
        expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
      end
    end

  end

  context "POST /projects" do
    context 'when unauthenticated' do
      it 'should return a 401 with a proper error' do
        post "#{host}/projects", { data: { type: "projects" } }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context 'when authenticated' do
      before do
        @user = create(:user, email: "test_user@mail.com", password: "password")
        @token = authenticate(email: "test_user@mail.com", password: "password")
      end

      it 'returns an error if title is left blank' do
        authenticated_post "/projects", {
          data: {
            attributes: { description: "Test project description" },
            relationships: { owner: { data: { id: @user.id, type: "User" } } }
          }
        }, @token

        expect(last_response.status).to eq 422
        expect(json).to be_a_valid_json_api_validation_error.with_message "can't be blank"
      end

      it "returns an error if owner is left blank" do
        authenticated_post "/projects", {
          data: {
            attributes: { title: "Test title", description: "Test project description" }
          }
        }, @token

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "ACCESS_DENIED"
        expect(json).to contain_an_error_of_type("ACCESS_DENIED").with_message("You are not authorized to perform this action on projects.")
      end

      it "returns a 404 if the owner doesn't exist" do
        authenticated_post "/projects", {
          data: {
            attributes: { title: "Project", description: "Test project description" },
            relationships: { owner: { data: { id: 222, type: "Organization" } } }
          }
        }, @token

        expect(last_response.status).to eq 404
        expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
      end

      context 'with a user uploaded image' do
        it 'creates a project' do
          Sidekiq::Testing.inline! do
            file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
            base64_image = Base64.encode64(open(file) { |io| io.read })

            authenticated_post "/projects", {
              data: {
                attributes: {
                  title: "Test Project Title",
                  slug: "test-project",
                  description: "Test project description",
                  base64_icon_data: base64_image
                },
                relationships: { owner: { data: { id: @user.id, type: "User" } } }
              }
            }, @token

            expect(last_response.status).to eq 200

            project = Project.last

            expect(project.base64_icon_data).to be_nil
            expect(project.icon.path).to_not be_nil
            expect(project.title).to eq "Test Project Title"
            expect(project.description).to eq "Test project description"
            # expect icon saved from create action to be identical to our test photor
            project_icon_file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
            base64_saved_image = Base64.encode64(open(project_icon_file) { |io| io.read })
            expect(base64_saved_image).to include base64_image
          end
        end
      end

      context 'without a user uploaded image' do
        it 'creates a project' do
          authenticated_post "/projects", {
              data: {
                attributes: {
                  title: "Test Project Title",
                  description: "Test project description",
                },
                relationships: { owner: { data: { id: @user.id, type: "User" } } }
              }
            }, @token

            expect(last_response.status).to eq 200

            project = Project.last

            expect(project.icon.path).to be_nil
            expect(project.title).to eq "Test Project Title"
            expect(project.description).to eq "Test project description"
        end
      end
    end
  end

  context 'PATCH /projects/:id' do

     let(:project) { create(:project) }

    context 'when unauthenticated' do
      it 'should return a 401 with a proper error' do
        patch "#{host}/projects/#{project.id}", { data: { type: "projects" } }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context 'when authenticated' do
      before do
        @project = create(:project, owner: create(:user, email: "test_user@mail.com", password: "password"))
        @token = authenticate(email: "test_user@mail.com", password: "password")
      end

      it "returns a 404 if the project doesn't exist" do
        authenticated_patch "/projects/22", {
          data: {
            attributes: { title: "Project", description: "Test project description" },
          }
        }, @token

        expect(last_response.status).to eq 404
        expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
      end

      context 'when updating the title' do
        it 'updates a project title' do
          authenticated_patch "/projects/#{@project.id}", {
            data: {
              attributes: {
                title: "New title"
              }
            }
          }, @token

          @project.reload

          expect(@project.title).to eq "New title"
        end

        it 'returns an error when with a nil title' do
          authenticated_patch "/projects/#{@project.id}", {
              data: {
                attributes: {
                  title: nil
                }
              }
            }, @token

          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_validation_error.with_message "can't be blank"
        end
      end

      it 'updates a project description' do
        authenticated_patch "/projects/#{@project.id}", {
          data: {
            attributes: {
              description: "New description"
            }
          }
        }, @token

        @project.reload

        expect(@project.description).to eq "New description"
      end

      it 'updates a project icon for a project without an icon' do
        Sidekiq::Testing.inline! do
          file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
          base64_image = Base64.encode64(open(file) { |io| io.read })

          authenticated_patch "/projects/#{@project.id}", {
            data: {
              attributes: {
                base64_icon_data: base64_image
              }
            }
          }, @token

          @project.reload

          expect(@project.base64_icon_data).to be_nil
          expect(@project.icon.path).to_not be_nil
          project_icon_file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
          base64_saved_image = Base64.encode64(open(project_icon_file) { |io| io.read })
          expect(base64_saved_image).to include base64_image
        end
      end
    end
  end
end
