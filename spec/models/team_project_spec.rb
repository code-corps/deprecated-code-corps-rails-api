# == Schema Information
#
# Table name: team_projects
#
#  id         :integer          not null, primary key
#  team_id    :integer          not null
#  project_id :integer          not null
#  role       :string           default("regular"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

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
end
