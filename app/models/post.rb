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

require "html/pipeline"
require "html/pipeline/rouge_filter"
require "code_corps/scenario/generate_user_mentions_for_post"

class Post < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :project

  has_many :comments
  has_many :post_likes
  has_many :post_user_mentions
  has_many :comment_user_mentions

  acts_as_sequenced scope: :project_id, column: :number, skip: ->(r) { r.draft? }

  validates_presence_of :project
  validates_presence_of :user

  validates :title, presence: true, unless: :draft?
  validates :body, presence: true, unless: :draft?
  validates :markdown, presence: true, unless: :draft?

  validates_presence_of :post_type

  validates_uniqueness_of :number, scope: :project_id, allow_nil: true

  before_validation :render_markdown_to_body
  before_validation :publish_changes

  after_create :track_created

  after_save :generate_mentions

  attr_accessor :publishing
  alias_method :publishing?, :publishing

  enum status: {
    open: "open",
    closed: "closed"
  }

  enum post_type: {
    idea: "idea",
    progress: "progress",
    task: "task",
    issue: "issue"
  }

  aasm do
    state :draft, initial: true
    state :published
    state :edited

    event :publish, after: :track_published do
      transitions from: :draft, to: :published
    end

    event :edit, after: :track_edited do
      transitions from: :published, to: :edited
    end
  end

  default_scope  { order(number: :desc) }

  scope :active, -> { where("aasm_state=? OR aasm_state=?", "published", "edited") }

  def update(publishing)
    @publishing = publishing
    save
  end

  def state
    aasm_state
  end

  def state=(value)
    publish if value == "published" && draft?
  end

  def edited_at
    updated_at if edited?
  end

  private

    def generate_mentions
      CodeCorps::Scenario::GenerateUserMentionsForPost.new(self).call
    end

    def pipeline
      @pipeline ||= HTML::Pipeline.new [
        HTML::Pipeline::MarkdownFilter,
        HTML::Pipeline::RougeFilter
      ], gfm: true # Github-flavored markdown
    end

    def publish_changes
      return unless publishing?

      edit if published?
      publish if draft?

      assign_attributes markdown: markdown_preview, body: body_preview
    end

    def render_markdown_to_body
      return unless markdown_preview_changed?
      html = pipeline.call(markdown_preview)
      self.body_preview = html[:output].to_s
    end

    def track_created
      analytics.track_created_post(self)
    end

    def track_edited
      analytics.track_edited_post(self)
    end

    def track_published
      analytics.track_published_post(self)
    end

    def analytics
      @analytics ||= Analytics.new(user)
    end
end
