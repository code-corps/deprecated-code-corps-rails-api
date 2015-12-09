require 'html/pipeline'
require 'code_corps/scenario/generate_user_mentions_for_post'

class Post < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :project

  has_many :comments
  has_many :post_likes
  has_many :post_user_mentions

  acts_as_sequenced scope: :project_id, column: :number, skip: lambda { |r| r.draft? }

  validates_presence_of :project
  validates_presence_of :user
  validates_presence_of :title
  validates_presence_of :body
  validates_presence_of :markdown

  validates_uniqueness_of :number, scope: :project_id, allow_nil: true

  before_validation :render_markdown_to_body

  after_save :generate_mentions # Still safe because it runs inside transaction

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

    event :publish do
      transitions from: :draft, to: :published
    end
  end

  def likes_count
    self.post_likes_count
  end

  private

    def generate_mentions
      CodeCorps::Scenario::GenerateUserMentionsForPost.new(self).call
    end

    def render_markdown_to_body
      if markdown.present?
        html = pipeline.call(markdown)
        self.body = html[:output].to_s
      end
    end

    def pipeline
      @pipeline ||= HTML::Pipeline.new [
        HTML::Pipeline::MarkdownFilter
      ], {
        gfm: true # Github-flavored markdown
      }
    end
end
