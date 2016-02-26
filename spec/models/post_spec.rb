# == Schema Information
#
# Table name: posts
#
#  id               :integer          not null, primary key
#  status           :string           default("open")
#  post_type        :string           default("task")
#  title            :string
#  body             :text
#  user_id          :integer          not null
#  project_id       :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  post_likes_count :integer          default(0)
#  markdown         :text
#  number           :integer
#  aasm_state       :string
#  comments_count   :integer          default(0)
#  body_preview     :text
#  markdown_preview :text
#

require "rails_helper"

describe Post, type: :model do
  describe "schema" do
    it { should have_db_column(:status).of_type(:string) }
    it { should have_db_column(:post_type).of_type(:string) }
    it { should have_db_column(:title).of_type(:string).with_options(null: true) }
    it { should have_db_column(:body).of_type(:text).with_options(null: true) }
    it { should have_db_column(:markdown).of_type(:text).with_options(null: true) }
    it { should have_db_column(:body_preview).of_type(:text).with_options(null: true) }
    it { should have_db_column(:markdown_preview).of_type(:text).with_options(null: true) }
    it { should have_db_column(:project_id).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:user_id).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:updated_at) }
    it { should have_db_column(:created_at) }
    it { should have_db_column(:post_likes_count).of_type(:integer) }
    it { should have_db_column(:aasm_state).of_type(:string) }
    it { should have_db_column(:comments_count).of_type(:integer) }
  end

  describe "relationships" do
    it { should have_many(:comments) }
    it { should belong_to(:project) }
    it { should belong_to(:user) }
    it { should have_many(:post_likes) }
    it { should have_many(:post_user_mentions) }
    it { should have_many(:comment_user_mentions) }
  end

  describe "validations" do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:project) }

    it { should validate_presence_of(:post_type) }

    context "number" do
      let(:subject) { create(:post) }
      it { should validate_uniqueness_of(:number).scoped_to(:project_id).allow_nil }
    end

    context "when post is draft" do
      let(:subject) { create(:post, :draft) }
      it { should_not validate_presence_of(:title) }
      it { should_not validate_presence_of(:body) }
      it { should_not validate_presence_of(:markdown) }
    end

    context "when post is published" do
      let(:subject) { create(:post, :published) }
      it { should validate_presence_of(:title) }
      it { should validate_presence_of(:body) }
      it { should validate_presence_of(:markdown) }
    end

    context "when post is edited" do
      let(:subject) { create(:post, :edited) }
      it { should validate_presence_of(:title) }
      it { should validate_presence_of(:body) }
      it { should validate_presence_of(:markdown) }
    end
  end

  describe "behavior" do
    it { should define_enum_for(:status).with({ open: "open", closed: "closed" }) }
    it { should define_enum_for(:post_type).with({ idea: "idea", progress: "progress", task: "task", issue: "issue" }) }
  end

  describe ".state" do
    it "should return the aasm_state" do
      post = create(:post)
      expect(post.state).to eq post.aasm_state
    end
  end

  describe ".edited_at" do
    context "when the post hasn't been edited" do
      it "returns nil" do
        post = create(:post)
        expect(post.edited_at).to eq nil
      end
    end

    context "when the post has been edited" do
      it "returns the updated_at timestamp" do
        post = create(:post)
        post.publish
        post.edit

        expect(post.edited_at).to eq post.updated_at
      end
    end
  end

  describe ".post_like_counts" do
    let(:user) { create(:user) }
    let(:post) { create(:post) }

    context "when there is no PostLike" do
      it "should have the correct counter cache" do
        expect(post.likes_count).to eq 0
      end
    end

    context "when there is a PostLike" do
      it "should have the correct counter cache" do
        create(:post_like, user: user, post: post)
        expect(post.likes_count).to eq 1
      end
    end
  end

  describe "sequencing" do
    context "when a draft" do
      it "does not number the post" do
        project = create(:project)
        first_post = create(:post, project: project)

        expect(first_post.number).to be_nil
      end
    end

    context "when published with bang (auto-save) methods" do
      it "numbers posts for each project" do
        project = create(:project)
        first_post = create(:post, project: project)
        second_post = create(:post, project: project)
        first_post.publish!
        second_post.publish!

        expect(first_post.number).to eq 1
        expect(second_post.number).to eq 2
      end

      it "should not allow a duplicate number to be set for the same project" do
        project = create(:project)
        first_post = create(:post, project: project)
        first_post.publish!

        expect { create(:post, project: project, number: 1) }.to raise_error ActiveRecord::RecordInvalid
      end
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

  describe "#update" do
    it "renders markdown_preview to body_preview" do
      post = build(:post, markdown_preview: "# Hello World\n\nHello, world.")
      post.update(false)
      expect(post.body_preview).to eq "<h1>Hello World</h1>\n\n<p>Hello, world.</p>"
    end

    it "overwrites existing body_preview if new markdown_preview is emtpy" do
      post = build(:post, body_preview: "<p>There's something happening here</p>")
      post.markdown_preview = "what it is aint exactly clear"
      post.update(false)
      expect(post.body_preview).to eq "<p>what it is aint exactly clear</p>".html_safe
    end

    context "when previewing" do
      it "should just save a draft post" do
        post = create(:post, :draft)
        expect(post.update(false)).to be true

        expect(post.draft?).to be true
      end

      it "should just save a published post" do
        post = create(:post, :published)
        expect(post.update(false)).to be true

        expect(post.published?).to be true
      end

      it "should just save an edited post" do
        post = create(:post, :edited)
        expect(post.update(false)).to be true

        expect(post.edited?).to be true
      end
    end

    context "when publishing" do
      it "publishes a draft post" do
        post = create(:post, :draft)
        expect(post.update(true)).to be true

        expect(post.published?).to be true
      end

      it "just saves a published post, sets it to edited state" do
        post = create(:post, :published)
        expect(post.update(true)).to be true

        expect(post.edited?).to be true
      end

      it "just saves an edited post" do
        post = create(:post, :edited)
        expect(post.update(true)).to be true

        expect(post.edited?).to be true
      end
    end
  end

  describe "publishing" do
    let(:post) { create(:post) }

    it "publishes when state is set to 'published'" do
      post.state = "published"
      post.save

      expect(post).to be_published
    end
  end

  describe "default_scope" do
    it "orders by number by default" do
      create_list(:post, 3, :published, :with_number)
      posts = Post.all
      expect(posts.map(&:number)).to eq [3, 2, 1]
    end
  end

  describe "post user mentions" do
    context "when updating a post" do
      it "creates mentions only for existing users" do
        real_user = create(:user, username: "joshsmith")

        post = build(:post, markdown_preview: "Hello @joshsmith and @someone_who_doesnt_exist")

        post.update(false)
        mentions = post.post_user_mentions

        expect(mentions.count).to eq 1
        expect(mentions.first.user).to eq real_user
      end

      context "when mentions already exist" do
        let(:post) do
          post = create(:post, markdown_preview: "Hello @joshsmith")
          create(:user, username: "joshsmith")
          create_list(:post_user_mention, 2, post: post, status: :published)
          create_list(:post_user_mention, 3, post: post, status: :preview)
          post
        end

        it "destroys preview mentions if preview was requested, leaves published mentions" do
          post.update(false)
          expect(post.post_user_mentions.published.count).to eq 2
          expect(post.post_user_mentions.preview.count).to eq 1
        end

        it "destroys published mentions if publish was requested, leaves preview mentions" do
          post.update(true)
          expect(post.post_user_mentions.published.count).to eq 1
          expect(post.post_user_mentions.preview.count).to eq 3
        end
      end

      context "when usernames contain underscores" do
        it "creates mentions and not <em> tags" do
          underscored_user = create(:user, username: "a_real_username")

          post = build(:post, markdown_preview: "Hello @a_real_username and @not_a_real_username")
          post.update(false)
          mentions = post.post_user_mentions

          expect(mentions.count).to eq 1
          expect(mentions.first.user).to eq underscored_user
        end
      end
    end
  end
end
