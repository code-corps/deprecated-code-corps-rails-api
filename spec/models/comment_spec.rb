# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  body             :text
#  user_id          :integer          not null
#  post_id          :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  markdown         :text
#  aasm_state       :string
#  body_preview     :text
#  markdown_preview :text
#

require 'rails_helper'

describe Comment, :type => :model do
  describe "schema" do
    it { should have_db_column(:body).of_type(:text).with_options(null: false) }
    it { should have_db_column(:markdown).of_type(:text).with_options(null: false) }
    it { should have_db_column(:post_id).of_type(:integer) }
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:updated_at) }
    it { should have_db_column(:created_at) }
    it { should have_db_column(:aasm_state).of_type(:string) }
  end

  describe "relationships" do
    it { should belong_to(:post).counter_cache true }
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

  describe "state machine" do
    let(:post) { Post.new }

    it "sets the state to draft initially" do
      expect(post).to have_state(:draft)
    end

    it "transitions correctly" do
      expect(post).to transition_from(:draft).to(:published).on_event(:publish)
    end
  end

  describe ".state" do
    it "should return the aasm_state" do
      comment = create(:comment)
      expect(comment.state).to eq comment.aasm_state
    end
  end

  describe ".edited_at" do
    context "when the comment hasn't been edited" do
      it "returns nil" do
        comment = create(:comment)
        expect(comment.edited_at).to eq nil
      end
    end

    context "when the comment has been edited" do
      it "returns the updated_at timestamp" do
        comment = create(:comment)
        comment.publish
        comment.edit

        expect(comment.edited_at).to eq comment.updated_at
      end
    end
  end

  describe ".update!" do
    context "when aasm_state_was 'published'" do
      context "when the model has changed" do
        it "should be edited" do
          comment = create(:comment)
          comment.publish!

          comment.markdown = "New markdown"
          comment.update!

          expect(comment).to be_edited
        end
      end

      context "when the model has not changed" do
        it "should still be published" do
          comment = create(:comment)
          comment.publish!

          comment.update!

          expect(comment).to be_published
        end
      end
    end

    context "when in draft state" do
      it "should still be draft but saved" do
        comment = create(:comment)
        old_updated_at = comment.updated_at
        comment.markdown = "New text"
        comment.update!

        expect(comment).to be_draft
        expect(comment.updated_at).not_to eq old_updated_at
      end
    end
  end

  describe "publishing" do
    let(:comment) { create(:comment) }

    it "publishes when state is set to 'published'" do
      comment.state = "published"
      comment.save

      expect(comment).to be_published
    end
  end

  describe "user mentions" do
    context "when saving a comment" do
      it "creates mentions only for existing users" do
        real_user = create(:user, username: "joshsmith")

        comment = Comment.create(
          post: create(:post),
          user: create(:user),
          markdown: "Hello @joshsmith and @someone_who_doesnt_exist"
        )

        comment.reload
        mentions = comment.comment_user_mentions

        expect(mentions.count).to eq 1
        expect(mentions.first.user).to eq real_user
      end

      context "when usernames contain underscores" do
        it "creates mentions and not <em> tags" do
          underscored_user = create(:user, username: "a_real_username")

          comment = Comment.create(
            post: create(:post),
            user: create(:user),
            markdown: "Hello @a_real_username and @not_a_real_username"
          )

          comment.reload
          mentions = comment.comment_user_mentions

          expect(mentions.count).to eq 1
          expect(mentions.first.user).to eq underscored_user
        end
      end
    end
  end
end
