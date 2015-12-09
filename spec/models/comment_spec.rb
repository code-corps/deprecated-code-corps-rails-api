require 'rails_helper'

describe Comment, :type => :model do
  describe "schema" do
    it { should have_db_column(:body).of_type(:text).with_options(null: false) }
    it { should have_db_column(:markdown).of_type(:text).with_options(null: false) }
    it { should have_db_column(:post_id).of_type(:integer) }
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:updated_at) }
    it { should have_db_column(:created_at) }
  end

  describe "relationships" do
    it { should belong_to(:post) }
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:post) }
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:markdown) }
  end

  describe "before_validation" do
    it "converts markdown to html for the body" do
      comment = create(:comment, markdown: "# Hello World\n\nHello, world.")
      comment.save

      comment.reload
      expect(comment.body).to eq "<h1>Hello World</h1>\n\n<p>Hello, world.</p>"
    end
  end
end
