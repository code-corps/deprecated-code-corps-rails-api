# == Schema Information
#
# Table name: post_likes
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe PostLike, type: :model do
  describe "schema" do
    it { should have_db_column(:post_id).of_type(:integer) }
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:updated_at) }
    it { should have_db_column(:created_at) }
  end

  describe "relationships" do
    it { should belong_to(:post).counter_cache true }
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of :user }
    it { should validate_presence_of :post }
    it { should validate_uniqueness_of(:post_id).scoped_to(:user_id) }
  end
end
