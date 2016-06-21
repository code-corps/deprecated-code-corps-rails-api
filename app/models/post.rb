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

  acts_as_sequenced scope: :project_id, column: :number

  validates :body, presence: true
  validates :markdown, presence: true
  validates :post_type, presence: true
  validates :project, presence: true
  validates :title, presence: true
  validates :user, presence: true

  validates_uniqueness_of :number, scope: :project_id, allow_nil: true

  before_validation :render_markdown_to_body

  after_create :track_created

  after_save :generate_mentions
  after_save :track_edited

  enum status: {
    open: "open",
    closed: "closed"
  }

  enum post_type: {
    idea: "idea",
    task: "task",
    issue: "issue"
  }

  aasm do
    state :published, initial: true
    state :edited

    event :edit do
      transitions from: :published, to: :edited
    end
  end

  default_scope { order(number: :desc) }

  def state
    aasm_state
  end

  def state=(value)
    edit if value == "edited" && published?
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

    def render_markdown_to_body
      html = pipeline.call(markdown)
      self.body = html[:output].to_s
    end

    def track_created
      analytics.track_created_post(self)
    end

    def track_edited
      analytics.track_edited_post(self) if edited?
    end

    def analytics
      @analytics ||= Analytics.new(user)
    end
end
