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

  context "POST /:slug/" do

    context "when unauthenticated" do
      it "returns a 401" do
        post "#{host}/random_slug/"
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      before do
        create(:user, email: "test@coderly.com", password: "password")
        @token = authenticate(email: "test@coderly.com", password: "password")

        @valid_attributes = { data: { attributes: {
          title: "ProjectTitle",
          description: "Project description",
        } } }

        @invalid_attributes = { data: { attributes: { description: "Project description " } } }

      end

      context "when the owner doesn't exist" do
        it "responds with a 404" do
          authenticated_post "/random_slug", @valid_attributs, @token
          expect(last_response.status).to eq 404
          expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
        end
      end

      context "when the owner does exist" do
        before do
          @member = create(:organization).member
        end

        context "when attributes are invalid" do
          it 'responds with a validation error if title is left blank' do
            authenticated_post "/#{@member.slug}", @invalid_attributes, @token

            expect(json).to be_a_valid_json_api_error
            expect(json).to contain_an_error_of_type("VALIDATION_ERROR")
                              .with_message "Title may only contain alphanumeric characters, underscores, or single hyphens, and cannot begin or end with a hyphen or underscore"
          end
        end

        context "when succesful" do

          context "when there's no icon data" do
            before do
              Sidekiq::Testing.inline! { authenticated_post "/#{@member.slug}", @valid_attributes, @token }
            end

            it "responds with a 200" do
              expect(last_response.status).to eq 200
            end

            it "returns the project serialized with ProjectSerializer" do
              expect(json).to serialize_object(Project.last).with(ProjectSerializer)
            end

            it "creates a project" do
              project = Project.last
              expect(project.title).to eq "ProjectTitle"
              expect(project.description).to eq "Project description"
            end
          end


          context "when there's icon data" do
            before do
              file = File.open("#{Rails.root}/spec/sample_data/default-avatar.png", 'r')
              @base_64_image = Base64.encode64(open(file) { |io| io.read })

              @valid_attributes_with_icon_data = { data: { attributes: {
                title: "ProjectTitle",
                description: "Project description",
                base_64_icon_data: @base_64_image
              } } }

              Sidekiq::Testing.inline! { authenticated_post "/#{@member.slug}", @valid_attributes_with_icon_data, @token }
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

        end
      end
    end
  end

  context 'PATCH /:slug/:project_slug' do
    context "when unauthenticated" do
      it "returns a 401" do
        patch "#{host}/random_slug_1/random_slug_2"
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      before do
        create(:user, email: "test@coderly.com", password: "password")
        @token = authenticate(email: "test@coderly.com", password: "password")
        @valid_attributes = { data: { attributes: { title: "NewTitle", description: "New description" } } }
        @invalid_attributes = { data: { attributes: { title: "New title", description: "New description" } } }
      end

      context "when the owner doesn't exist" do
        it "responds with a 404" do
          authenticated_patch "/random_slug_1/random_slug_2", @valid_attributes, @token
          expect(last_response.status).to eq 404
          expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
        end
      end

      context "when the project doesn't exist" do
        before do
          @member = create(:organization).member
        end

        it "responds with a 404" do
          authenticated_patch "/#{@member.slug}/random_slug", @valid_attributes, @token
          expect(last_response.status).to eq 404
          expect(json).to be_a_valid_json_api_error.with_id "RECORD_NOT_FOUND"
        end
      end

      context "when the project exists" do
        before do
          @project = create(:project, owner: create(:organization))
        end

        context "when patching with valid attributes" do
          before do
            authenticated_patch "/#{@project.owner.member.slug}/#{@project.slug}", @valid_attributes, @token
          end

          it "responds with a 200" do
            expect(last_response.status).to eq 200
          end

          it "patches the project record" do
            project = @project.reload
            expect(project.title).to eq "NewTitle"
            expect(project.description).to eq "New description"
          end

          it "returns the patched project, serialized with ProjectSerializer" do
            expect(json).to serialize_object(@project.reload).with(ProjectSerializer)
          end
        end

        context "when patching with invalid attributes" do
          before do
            authenticated_patch "/#{@project.owner.member.slug}/#{@project.slug}", @invalid_attributes, @token
          end

          it "responds with a 422" do
            expect(last_response.status).to eq 422
          end

          it "returns  JSON API validation error" do
            expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
          end
        end
      end
    end
  end
end
