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

require 'html/pipeline'
require 'code_corps/scenario/generate_user_mentions_for_comment'

class Comment < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :post, counter_cache: true

  has_many :comment_user_mentions

  validates_presence_of :body
  validates_presence_of :markdown
  validates_presence_of :user
  validates_presence_of :post

  before_validation :render_markdown_to_body

  after_save :generate_mentions # Still safe because it runs inside transaction

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
      CodeCorps::Scenario::GenerateUserMentionsForComment.new(self).call
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
