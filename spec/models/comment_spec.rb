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

require "rails_helper"

describe Comment, type: :model do
  describe "schema" do
    it { should have_db_column(:body).of_type(:text).with_options(null: true) }
    it { should have_db_column(:markdown).of_type(:text).with_options(null: true) }
    it { should have_db_column(:body_preview).of_type(:text).with_options(null: true) }
    it { should have_db_column(:markdown_preview).of_type(:text).with_options(null: true) }
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

    context "when comment is draft" do
      let(:subject) { create(:comment, :draft) }
      it { should_not validate_presence_of(:body) }
      it { should_not validate_presence_of(:markdown) }
    end

    context "when comment is published" do
      let(:subject) { create(:comment, :published) }
      it { should validate_presence_of(:body) }
      it { should validate_presence_of(:markdown) }
    end

    context "when comment is edited" do
      let(:subject) { create(:comment, :edited) }
      it { should validate_presence_of(:body) }
      it { should validate_presence_of(:markdown) }
    end
  end

  describe "state machine" do
    let(:post) { create(:post) }
    let(:user) { create(:user) }
    let(:comment) { Comment.new(post: post, user: user) }

    it "sets the state to draft initially" do
      expect(comment).to have_state(:draft)
    end

    it "transitions correctly" do
      expect(comment).to transition_from(:draft).to(:published).on_event(:publish)
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

  describe "#update" do
    it "renders markdown_preview to body_preview" do
      comment = build(:comment, markdown_preview: "# Hello World\n\nHello, world.")
      comment.update(false)
      expect(comment.body_preview).to eq "<h1>Hello World</h1>\n\n<p>Hello, world.</p>"
    end

    it "overwrites existing body_preview if new markdown_preview is emtpy" do
      comment = create(:comment, body_preview: "<p>There's something happening here</p>")
      comment.markdown_preview = "what it is aint exactly clear"
      comment.update(false)
      expect(comment.body_preview).to eq "<p>what it is aint exactly clear</p>".html_safe
    end

    context "when previewing" do
      it "should just save a draft comment" do
        comment = create(:comment, :draft)
        expect(comment.update(false)).to be true

        expect(comment.draft?).to be true
        expect(comment.markdown_preview).not_to be_nil
        expect(comment.body_preview).not_to be_nil
        expect(comment.markdown).to be_nil
        expect(comment.body).to be_nil
      end

      it "should just save a published comment" do
        comment = create(:comment, :published)
        expect(comment.update(false)).to be true

        expect(comment.published?).to be true
        expect(comment.markdown_preview).not_to be_nil
        expect(comment.body_preview).not_to be_nil
        expect(comment.markdown).not_to be_nil
        expect(comment.body).not_to be_nil
      end

      it "should just save an edited comment" do
        comment = create(:comment, :edited)
        expect(comment.update(false)).to be true

        expect(comment.edited?).to be true
        expect(comment.markdown_preview).not_to be_nil
        expect(comment.body_preview).not_to be_nil
        expect(comment.markdown).not_to be_nil
        expect(comment.body).not_to be_nil
      end
    end

    context "when publishing" do
      it "publishes a draft comment" do
        expect_any_instance_of(Analytics).to receive(:track_published_comment)

        comment = create(:comment, :draft)
        expect(comment.update(true)).to be true

        expect(comment.published?).to be true
      end

      it "just saves a published comment, sets it to edited state" do
        expect_any_instance_of(Analytics).to receive(:track_edited_comment)

        comment = create(:comment, :published)
        expect(comment.update(true)).to be true

        expect(comment.edited?).to be true
      end

      it "just saves an edited comment" do
        comment = create(:comment, :edited)
        expect(comment.update(true)).to be true

        expect(comment.edited?).to be true
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

        comment = build(:comment, markdown_preview: "@joshsmith and @someone_who_doesnt_exist")

        comment.update(false)
        mentions = comment.comment_user_mentions

        expect(mentions.count).to eq 1
        expect(mentions.first.user).to eq real_user
      end

      context "when mentions already exist" do
        let(:comment) do
          comment = create(:comment, markdown_preview: "Hello @joshsmith")
          create(:user, username: "joshsmith")
          create_list(:comment_user_mention, 2, comment: comment, status: :published)
          create_list(:comment_user_mention, 3, comment: comment, status: :preview)
          comment
        end

        it "destroys preview mentions if preview was requested, leaves published mentions" do
          comment.update(false)
          expect(comment.comment_user_mentions.published.count).to eq 2
          expect(comment.comment_user_mentions.preview.count).to eq 1
        end

        it "destroys published mentions if publish was requested, leaves preview mentions" do
          comment.update(true)
          expect(comment.comment_user_mentions.published.count).to eq 1
          expect(comment.comment_user_mentions.preview.count).to eq 3
        end
      end

      context "when usernames contain underscores" do
        it "creates mentions and not <em> tags" do
          underscored_user = create(:user, username: "a_real_username")

          comment = build(:comment, markdown_preview: "@a_real_username and @not_a_real_username")

          comment.update(false)
          mentions = comment.comment_user_mentions

          expect(mentions.count).to eq 1
          expect(mentions.first.user).to eq underscored_user
        end
      end
    end
  end
end
