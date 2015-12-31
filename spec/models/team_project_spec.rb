require "rails_helper"

describe TeamProject, type: :model do
  describe "schema" do
    it { should have_db_column(:team_id).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:project_id).of_type(:integer).with_options(null: false) }
    it { should have_db_index([:team_id, :project_id]).unique }
  end

  describe "relationships" do
    it { should belong_to(:team) }
    it { should belong_to(:project) }
  end

  describe "validations" do
    it { should validate_presence_of(:project) }
    it { should validate_presence_of(:team) }
    it {  create(:team_project); should validate_uniqueness_of(:project_id).scoped_to(:team_id) }
  end

  it "should have a working 'role' enum" do
    team_project = create(:team_project)

    expect(team_project.admin?).to be false
    expect(team_project.regular?).to be true

    team_project.admin!
    expect(team_project.admin?).to be true
    expect(team_project.regular?).to be false

    team_project.regular!
    expect(team_project.admin?).to be false
    expect(team_project.regular?).to be true
  end

  describe "#role_value" do
    it "should return 0 for regular" do
      team_project = create(:team_project)
      team_project.regular!

      expect(team_project.role_value).to eq 0
    end

    it "should return 1 for admin" do
      team_project = create(:team_project)
      team_project.admin!

      expect(team_project.role_value).to eq 1
    end

    it "should rank admin higher than regular" do
      admin_team_project = create(:team_project)
      admin_team_project.admin!

      regular_team_project = create(:team_project)
      regular_team_project.regular!

      array = [admin_team_project, regular_team_project]
      max = array.max_by { |item| item.role_value }
      expect(max).to be admin_team_project
    end
  end
end
