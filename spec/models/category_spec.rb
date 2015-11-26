require 'rails_helper'

describe Category, type: :model do
  describe "schema" do
    it { should have_db_column(:title).of_type(:string).with_options(null: false) }
  end

  describe "relationships" do
    it { should have_many(:skills) }
  end
end
