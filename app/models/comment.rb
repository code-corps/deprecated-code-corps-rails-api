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

require "html/pipeline"
require "html/pipeline/rouge_filter"
require "code_corps/scenario/generate_user_mentions_for_comment"

class Comment < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :post, counter_cache: true

  has_many :comment_user_mentions

  validates :body, presence: true
  validates :markdown, presence: true
  validates :post, presence: true
  validates :user, presence: true

  before_validation :render_markdown_to_body

  after_create :track_created

  after_save :generate_mentions
  after_save :track_edited

  aasm do
    state :published, initial: true
    state :edited

    event :edit do
      transitions from: :published, to: :edited
    end
  end

  default_scope { order(id: :asc) }

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
      CodeCorps::Scenario::GenerateUserMentionsForComment.new(self).call
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
      analytics.track_created_comment(self)
    end

    def track_edited
      analytics.track_edited_comment(self) if edited?
    end

    def analytics
      @analytics ||= Analytics.new(user)
    end
end
