require "rails_helper"

describe "Team Projects API" do

  context "POST /team_projects" do

    context "When Unauthenticated" do
      before do
        @project = create(:project)
        @team = create(:team)
      end

      it 'should return a 401 with a proper error' do

        post "#{host}/team_projects", { 
          data: {
            attributes: {
              project_id: @project.id,
              team_id: @team.id,
              role: "regular"
            }
          }
        }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end
    context "When authenticated" do
      context "and authorized" do
        before do
          @project = create(:project)
          @team = create(:team)
          @user = create(:user, email: "test_user@mail.com", password: "password")
          @token = authenticate(email: "test_user@mail.com", password: "password")
          @contributor = create(:contributor, user: @user, project: @project, status: "admin")
        end

        it 'should return the team_project with a 200 status' do
          authenticated_post "/team_projects", { 
            data: {
              attributes: {
                project_id: @project.id,
                team_id: @team.id,
                role: "regular"
              }
            }
          }, @token
          expect(last_response.status).to eq 200

          expect(TeamProject.last.team_id).to eq @team.id
          expect(TeamProject.last.project_id).to eq @project.id
        end
      end

      context "and unauthorized" do 
        before do
          @project = create(:project)
          @team = create(:team)
          @user = create(:user, email: "test_user@mail.com", password: "password")
          @token = authenticate(email: "test_user@mail.com", password: "password")
          @contributor = create(:contributor, user: @user, project: @project)
        end

        it 'should return an error with a 200 status' do
          authenticated_post "/team_projects", { 
            data: {
              attributes: {
                project_id: @project.id,
                team_id: @team.id,
                role: "regular"
              }
            }
          }, @token
          expect(last_response.status).to eq 401

          expect(json).to be_a_valid_json_api_error.with_id "ACCESS_DENIED"
        end
      end
    end
  end

  context "PATCH /team_projects" do
    before do
      @project = create(:project)
      @team = create(:team)
      @user = create(:user, email: "test_user@mail.com", password: "password")
      @contributor = create(:contributor, user: @user, project: @project, status: "admin")
      @token = authenticate(email: "test_user@mail.com", password: "password")

      authenticated_post "/team_projects", { 
        data: {
          attributes: {
            project_id: @project.id,
            team_id: @team.id,
            role: "regular"
          }
        }
      }, @token
    end
    context "When Unauthenticated" do
      it 'should return a 401 with a proper error' do

        patch "#{host}/team_projects/#{TeamProject.last.id}", { 
          data: {
            attributes: {
              project_id: @project.id,
              team_id: @team.id,
              role: "regular"
            }
          }
        }
        expect(last_response.status).to eq 401
        expect(json).to be_a_valid_json_api_error.with_id "NOT_AUTHORIZED"
      end
    end

    context "When authenticated" do
      it 'should return the team_project with a 200 status' do

        authenticated_patch "/team_projects/#{TeamProject.last.id}", { 
          data: {
            attributes: {
              project_id: @project.id,
              team_id: @team.id,
              role: "admin"
            }
          }
        }, @token
        expect(last_response.status).to eq 200
        expect(TeamProject.last.role).to eq "admin"
      end
    end
  end
end