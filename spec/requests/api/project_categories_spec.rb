require "rails_helper"

describe "ProjectCategories API" do
  describe "POST /project_categories" do
    context "when unauthenticated" do
      it "responds with a 401" do
        post "#{host}/project_categories", data: {}
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

      before do
        @user = create(:user, email: "josh@coderly.com", password: "password")
        organization = create(:organization)
        @project = create(:project, organization: organization)
        @category = create(:category)
        create(:organization_membership, role: "admin", member: @user, organization: organization)
      end

      context "when creation is succesful" do
        before do
          authenticated_post "/project_categories", { data: { relationships: {
            project: {
              data: {
                type: "projects", id: @project.id
              }
            },
            category: {
              data: {
                type: "categories", id: @category.id
              }
            }
          } } }, token
        end

        it "responds with the created project_category" do
          expect(last_response.status).to eq 200
        end

        it "sets category to current category" do
          expect(json.data.relationships.category.data.id).to eq @category.id.to_s
          expect(ProjectCategory.last.category).to eq @category
        end

        it "sets project to provided project" do
          expect(json.data.relationships.project.data.id).to eq @project.id.to_s
          expect(ProjectCategory.last.project).to eq @project
        end

        it "includes category in the response" do
          expect(json.included).not_to be_nil

          included_categories = json.included.select { |i| i.type == "categories" }
          expect(included_categories.count).to eq 1
        end

        it "includes project in the response" do
          expect(json.included).not_to be_nil

          included_categories = json.included.select { |i| i.type == "projects" }
          expect(included_categories.count).to eq 1
        end
      end

      context "when that project_category already exists" do
        before do
          create(:project_category, category: @category, project: @project)
          authenticated_post "/project_categories", { data: { relationships: {
            project: {
              data: {
                type: "projects", id: @project.id
              }
            },
            category: {
              data: {
                type: "categories", id: @category.id
              }
            }
          } } }, token
        end

        it "fails with a validation error" do
          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
        end
      end

      context "when there's no project with the specified id" do
        it "fails with a validation error" do
          authenticated_post "/project_categories", { data: { relationships: {
            project: { data: { type: "projects", id: 55 } },
            category: {
              data: {
                type: "categories", id: @category.id
              }
            }
          } } }, token

          expect(last_response.status).to eq 422
          expect(json).to be_a_valid_json_api_error.with_id "VALIDATION_ERROR"
        end
      end

      it "requires a category to be specified" do
        authenticated_post "/project_categories", { data: { relationships: {} } }, token
        expect(last_response.status).to eq 400
        expect(json).to be_a_valid_json_api_error.with_id "PARAMETER_MISSING"
      end

      it "requires a project to be specified" do
        authenticated_post "/project_categories", { data: { relationships: {
          category: {
            data: {
              type: "categories", id: @category.id
            }
          }
        } } }, token
        expect(last_response.status).to eq 400
        expect(json).to be_a_valid_json_api_error.with_id "PARAMETER_MISSING"
      end
    end
  end

  describe "DELETE /project_categories/:id" do
    context "when unauthenticated" do
      it "responds with a 401" do
        delete "#{host}/project_categories/1"

        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "josh@coderly.com", password: "password") }

      before do
        @user = create(:user, email: "josh@coderly.com", password: "password")
        organization = create(:organization)
        @project = create(:project, organization: organization)
        @category = create(:category)
        create(:organization_membership, role: "admin", member: @user, organization: organization)
      end

      context "without admin access" do
        before do
          @user = create(:user, email: "random@user.com", password: "password")
        end

        let(:token) { authenticate(email: "random@user.com", password: "password") }

        it "returns a 401 access denied" do
          create(:project_category, id: 1, category: @category, project: @project)

          authenticated_delete "/project_categories/1", {}, token

          expect(last_response.status).to eq 403
          expect(json).to be_a_valid_json_api_error.with_id "FORBIDDEN"
          expect(ProjectCategory.count).to eq 1
        end
      end

      context "when deletion is successful" do
        before do
          create(:project_category, id: 1, category: @category, project: @project)
          authenticated_delete "/project_categories/1", {}, token
        end

        it "responds with a 204" do
          expect(last_response.status).to eq 204
        end

        it "deletes the project_category" do
          expect(ProjectCategory.count).to eq 0
        end

        it "leaves category and project untouched" do
          expect(Category.count).to eq 1
          expect(Project.count).to eq 1
        end
      end
    end
  end
end
