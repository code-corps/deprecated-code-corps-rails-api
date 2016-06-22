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
#

require "rails_helper"

describe Post, type: :model do
  describe "schema" do
    it { should have_db_column(:status).of_type(:string) }
    it { should have_db_column(:post_type).of_type(:string) }
    it { should have_db_column(:title).of_type(:string).with_options(null: true) }
    it { should have_db_column(:body).of_type(:text).with_options(null: true) }
    it { should have_db_column(:markdown).of_type(:text).with_options(null: true) }
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
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:markdown) }
    it { should validate_presence_of(:post_type) }
    it { should validate_presence_of(:project) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:user) }

    context "number" do
      let(:subject) { create(:post) }
      it { should validate_uniqueness_of(:number).scoped_to(:project_id).allow_nil }
    end
  end

  describe "behavior" do
    it { should define_enum_for(:status).with(open: "open", closed: "closed") }
    it { should define_enum_for(:post_type).with(idea: "idea", task: "task", issue: "issue") }
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
        expect(post.post_likes_count).to eq 0
      end
    end

    context "when there is a PostLike" do
      it "should have the correct counter cache" do
        create(:post_like, user: user, post: post)
        expect(post.post_likes_count).to eq 1
      end
    end
  end

  describe "sequencing" do
    context "when created" do
      it "numbers posts for each project" do
        project = create(:project)
        first_post = create(:post, project: project, body: "A body")
        second_post = create(:post, project: project, body: "A body")

        expect(first_post.number).to eq 1
        expect(second_post.number).to eq 2
      end

      it "should not allow a duplicate number to be set for the same project" do
        project = create(:project)
        create(:post, project: project, body: "A body")

        expect { create(:post, project: project, number: 1) }.
          to raise_error ActiveRecord::RecordInvalid
      end
    end
  end

  describe "state machine" do
    let(:user) { create(:user) }
    let(:post) { Post.new(user: user) }

    it "sets the state to published initially" do
      expect(post).to have_state(:published)
    end

    it "transitions correctly" do
      expect(post).to transition_from(:published).to(:edited).on_event(:edit)
    end
  end

  describe "#save" do
    it "renders markdown to body" do
      post = build(:post, markdown: "# Hello World\n\nHello, world.")
      post.save
      expect(post.body).to eq "<h1>Hello World</h1>\n\n<p>Hello, world.</p>"
    end

    it "overwrites existing body if new markdown is emtpy" do
      post = build(:post, body: "<p>There's something happening here</p>")
      post.markdown = "what it is aint exactly clear"
      post.save
      expect(post.body).to eq "<p>what it is aint exactly clear</p>".html_safe
    end

    context "when editing" do
      it "just saves a published post, sets it to edited state" do
        expect_any_instance_of(Analytics).to receive(:track_edited_post)

        post = create(:post, :published)
        post.state = "edited"
        post.save

        expect(post.edited?).to be true
      end

      it "just saves an edited post" do
        post = create(:post, :edited)
        expect_any_instance_of(Analytics).to receive(:track_edited_post)
        post.state = "edited"
        post.save

        expect(post.edited?).to be true
      end
    end
  end

  describe "editing" do
    let(:post) { create(:post) }

    it "edits when state is set to 'edited'" do
      post.state = "edited"
      post.save

      expect(post).to be_edited
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

        post = build(:post, markdown: "Hello @joshsmith and @someone_who_doesnt_exist")
        post.save
        post.reload
        mentions = post.post_user_mentions

        expect(mentions.count).to eq 1
        expect(mentions.first.user).to eq real_user
      end

      context "when mentions already exist" do
        let(:post) do
          post = create(:post, markdown: "Hello @joshsmith")
          create(:user, username: "joshsmith")
          create_list(:post_user_mention, 2, post: post)
          post
        end

        it "destroys old mentions" do
          post.reload
          post.save
          expect(post.post_user_mentions.count).to eq 1
        end
      end

      context "when usernames contain underscores" do
        it "creates mentions and not <em> tags" do
          underscored_user = create(:user, username: "a_real_username")

          post = build(:post, markdown: "Hello @a_real_username and @not_a_real_username")
          post.save
          post.reload
          mentions = post.post_user_mentions

          expect(mentions.count).to eq 1
          expect(mentions.first.user).to eq underscored_user
        end
      end
    end
  end
end
