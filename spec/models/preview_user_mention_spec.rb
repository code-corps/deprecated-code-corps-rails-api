# == Schema Information
#
# Table name: preview_user_mentions
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  preview_id  :integer          not null
#  username    :string           not null
#  start_index :integer          not null
#  end_index   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require "rails_helper"

RSpec.describe PreviewUserMention, type: :model do
  describe "schema" do
    it { should have_db_column(:preview_id).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:user_id).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:username).of_type(:string).with_options(null: false) }
    it { should have_db_column(:start_index).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:end_index).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:updated_at) }
    it { should have_db_column(:created_at) }
  end

  describe "relationships" do
    it { should belong_to(:user) }
    it { should belong_to(:preview) }
  end

  describe "validations" do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:preview) }
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:start_index) }
    it { should validate_presence_of(:end_index) }
  end

  describe "before_validation" do
    it "automatically adds the user's username" do
      user = create(:user, username: "joshsmith")
      mention = create(:preview_user_mention, user: user)
      expect(mention.username).to eq "joshsmith"
    end
  end

  describe "indices" do
    it "wraps the indices inside of an array" do
      mention = create(:preview_user_mention, start_index: 0, end_index: 140)
      expect(mention.indices).to eq [0, 140]
    end
  end
end
