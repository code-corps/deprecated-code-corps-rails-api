require "rails_helper"

describe "Contributors API" do

  context "GET /contributors" do
    before do
      @project = create(:project)
      create_list(:contributor, 10, project: @project)
      create_list(:contributor, 5)
    end

    it "responds with a 400 if no filter is specified" do
      get "#{host}/contributors"
      expect(last_response.status).to eq 400
      expect(json).to be_a_valid_json_api_error.with_id "PARAMETER_MISSING"
    end

    context "when successful" do
      before do
        get "#{host}/contributors", { filter: { project_id: @project.id } }
      end

      it "returns a list of contributors for a project" do
        expect(last_response.status).to eq 200
        expect(json.data.length).to eq 10
      end

      it "includes users" do
        expect(json.included).not_to be_nil
        users = json.included.select { |i| i.type == "users" }
        expect(users.count).to eq 10
      end
      it "includes project" do
        expect(json.included).not_to be_nil
        projects = json.included.select { |i| i.type == "projects" }
        expect(projects.count).to eq 1
        expect(projects.first.id).to eq @project.id.to_s
      end
    end

  end

  context "POST /contributors" do
    it "requires authentication"
    it "requires a project to be specified"

    context "when successful" do
      it "returns the created contributor"
      it "sets contributor user to current user"
      it "sets contributor project to specified project"
      it "sets contributor status to 'pending'"
    end
  end

  context 'PATCH /contributors/:id' do
    it "requires authentication"

    it "allows a project admin to change 'pending' to 'collaborator'"

    it "does not allow a project admin to change anything to 'admin'"
    it "does not allow a project admin to change anything to 'owner'"
    it "does not allow a project admin to change anything to 'pending'"
    it "does not allow a project admin to change to anything from 'admin'"
    it "does not allow a project admin to change to anything from 'owner'"
    it "does not allow a project admin to change to anything from 'collaborator'"

    it "allows a project owner to change 'pending' to 'collaborator'"
    it "allows a project owner to change 'collaborator' to 'admin'"
    it "allows a project owner to change 'admin' to 'collaborator'"

    it "does not allow a project owner to change anything to 'pending'"

    it "does not allow a project owner to change anything to 'owner'"
    it "does not allow a project owner to change to anything from 'owner'"

    it "returns the updated contributor"
  end
end
