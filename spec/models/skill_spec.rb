require 'rails_helper'

describe Skill, type: :model do
  describe "schema" do
    it { should have_db_column(:title).of_type(:string).with_options(null: false) }
    it { should have_db_column(:description).of_type(:string) }
    it { should have_db_column(:category_id).of_type(:integer) }
  end

  describe "relationships" do
    it { should belong_to(:category) }
  end
end
