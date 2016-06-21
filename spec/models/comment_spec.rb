# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  body       :text
#  user_id    :integer          not null
#  post_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  markdown   :text
#  aasm_state :string
#

require "rails_helper"

describe Comment, type: :model do
  describe "schema" do
    it { should have_db_column(:body).of_type(:text).with_options(null: true) }
    it { should have_db_column(:markdown).of_type(:text).with_options(null: true) }
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
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:markdown) }
    it { should validate_presence_of(:post) }
    it { should validate_presence_of(:user) }
  end

  describe "state machine" do
    let(:post) { create(:post) }
    let(:user) { create(:user) }
    let(:comment) { Comment.new(post: post, user: user) }

    it "sets the state to draft initially" do
      expect(comment).to have_state(:published)
    end

    it "transitions correctly" do
      expect(comment).to transition_from(:published).to(:edited).on_event(:edit)
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
        comment.edit

        expect(comment.edited_at).to eq comment.updated_at
      end
    end
  end

  describe "#save" do
    it "renders markdown to body" do
      comment = build(:comment, markdown: "# Hello World\n\nHello, world.")
      comment.save
      expect(comment.body).to eq "<h1>Hello World</h1>\n\n<p>Hello, world.</p>"
    end

    it "overwrites existing body if new markdown is emtpy" do
      comment = create(:comment, body: "<p>There's something happening here</p>")
      comment.markdown = "what it is aint exactly clear"
      comment.save
      expect(comment.body).to eq "<p>what it is aint exactly clear</p>".html_safe
    end

    context "when editing" do
      it "just saves a published comment, sets it to edited state" do
        expect_any_instance_of(Analytics).to receive(:track_edited_comment)

        comment = create(:comment, :published)
        comment.state = "edited"
        comment.save

        expect(comment.edited?).to be true
      end

      it "just saves an edited comment" do
        comment = create(:comment, :edited)
        expect_any_instance_of(Analytics).to receive(:track_edited_comment)
        comment.save

        expect(comment.edited?).to be true
      end
    end
  end

  describe "editing" do
    let(:comment) { create(:comment) }

    it "edits when state is set to 'edited'" do
      comment.state = "edited"
      comment.save

      expect(comment).to be_edited
    end
  end

  describe "default_scope" do
    it "orders by id asc by default" do
      create_list(:comment, 3, :published)
      comments = Comment.all

      # Force the comments to change order
      comments.first.edit!

      comment_ids = comments.map(&:id)
      ids_ascending = comment_ids.sort
      expect(comment_ids).to eq ids_ascending
    end
  end

  describe "user mentions" do
    context "when updating a comment" do
      it "creates mentions only for existing users" do
        real_user = create(:user, username: "joshsmith")

        comment = build(:comment, markdown: "@joshsmith and @someone_who_doesnt_exist")
        comment.save
        comment.reload
        mentions = comment.comment_user_mentions

        expect(mentions.count).to eq 1
        expect(mentions.first.user).to eq real_user
      end

      context "when mentions already exist" do
        let(:comment) do
          comment = create(:comment, markdown: "Hello @joshsmith")
          create(:user, username: "joshsmith")
          create_list(:comment_user_mention, 2, comment: comment)
          comment
        end

        it "destroys old mentions" do
          comment.reload
          comment.save
          expect(comment.comment_user_mentions.count).to eq 1
        end
      end

      context "when usernames contain underscores" do
        it "creates mentions and not <em> tags" do
          underscored_user = create(:user, username: "a_real_username")

          comment = build(:comment, markdown: "@a_real_username and @not_a_real_username")
          comment.save
          comment.reload
          mentions = comment.comment_user_mentions

          expect(mentions.count).to eq 1
          expect(mentions.first.user).to eq underscored_user
        end
      end
    end
  end
end
