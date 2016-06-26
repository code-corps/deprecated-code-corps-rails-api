# == Schema Information
#
# Table name: import_skill_failures
#
#  id         :integer          not null, primary key
#  import_id  :integer          not null
#  skill_id   :integer
#  data       :json             not null
#  issues     :text             not null, is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

describe ImportSkillFailure, type: :model do
  describe "schema" do
    it { should have_db_column(:data).of_type(:json).with_options(null: false) }
    it { should have_db_column(:issues).of_type(:text).with_options(null: false) }

    it { should have_db_column(:updated_at) }
    it { should have_db_column(:created_at) }
  end

  describe "relationships" do
    it { should belong_to(:import) }
    it { should belong_to(:skill) }
  end

  describe "validations" do
    it { should validate_presence_of(:import) }
    it { should validate_presence_of(:issues) }
    it { should validate_presence_of(:data) }
  end
end
