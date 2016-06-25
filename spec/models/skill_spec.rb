# == Schema Information
#
# Table name: skills
#
#  id          :integer          not null, primary key
#  title       :string           not null
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require "rails_helper"

describe Skill, type: :model do
  describe "schema" do
    it { should have_db_column(:title).of_type(:string).with_options(null: false) }
    it { should have_db_column(:description).of_type(:string) }
  end

  describe "relationships" do
    it { should have_many(:role_skills) }
    it { should have_many(:roles).through(:role_skills) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
  end

  describe ".autocomplete" do
    it "autocompletes" do
      ruby = create(:skill, title: "Ruby")
      create(:skill, title: "Ruby on Rails")
      create(:skill, title: "RabbitMQ")
      create(:skill, title: "Rackspace Cloud Servers")
      create(:skill, title: "Redux.js")
      create(:skill, title: "Mustache")

      query = "ru"

      allow(Skill).to receive(:search).with(query) { Skill.all }

      results = Skill.autocomplete(query)
      expect(results.length).to eq 5
      expect(results.first).to eq ruby
    end
  end
end
