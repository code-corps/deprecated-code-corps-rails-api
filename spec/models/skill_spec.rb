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
    it { should have_db_column(:slug).of_type(:string).with_options(null: false) }
    it { should have_db_column(:description).of_type(:string) }
  end

  describe "relationships" do
    it { should have_many(:role_skills) }
    it { should have_many(:roles).through(:role_skills) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:slug) }

    describe "title" do
      describe "base validations" do
        # visit the following to understand why this is tested in a separate context
        # https://github.com/thoughtbot/shoulda-matchers/blob/master/lib/shoulda/matchers/active_record/validate_uniqueness_of_matcher.rb#L50
        subject { create(:skill) }
        it { should validate_uniqueness_of(:slug).case_insensitive }
      end

      it "should have profanity filter enabled" do
        skill = Skill.create(title: "Test")
        expect(skill.slug).to_not be_profane
      end

      it_behaves_like "a slug validating model", :slug

      # Checks reserved routes
      it { should_not allow_value("help").for(:slug) }
    end
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

  describe "slug" do
    it "gets auto-set from title on create" do
      skill = create(:skill, title: "Sluggable Skill")
      expect(skill.slug).to eq "sluggable-skill"
    end

    it "gets auto-set from title on update" do
      skill = create(:skill, title: "Sluggable Skill")
      skill.update(title: "New Sluggable Skill")
      expect(skill.slug).to eq "new-sluggable-skill"
    end
  end
end
