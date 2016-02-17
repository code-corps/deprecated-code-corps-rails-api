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

require 'html/pipeline'
require 'code_corps/scenario/generate_user_mentions_for_post'

class Post < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :project

  has_many :comments
  has_many :post_likes
  has_many :post_user_mentions
  has_many :comment_user_mentions

  acts_as_sequenced scope: :project_id, column: :number, skip: lambda { |r| r.draft? }

  validates_presence_of :project
  validates_presence_of :user
  validates_presence_of :title
  validates_presence_of :body
  validates_presence_of :markdown
  validates_presence_of :post_type

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
    state :edited

    event :publish do
      transitions from: :draft, to: :published
    end

    event :edit do
      transitions from: :published, to: :edited
    end
  end

  default_scope  { order(number: :desc) }

  scope :active, -> { published.merge edited }

  def likes_count
    self.post_likes_count
  end

  def update!
    if aasm_state_was == "published" && self.changed?
      self.edit!
    else
      self.save
    end
  end

  def state
    aasm_state
  end

  def state=(value)
    self.publish if value == "published" && self.draft?
  end

  def edited_at
    updated_at if edited?
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
