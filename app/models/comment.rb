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

require "html/pipeline"
require "code_corps/scenario/generate_user_mentions_for_comment"

class Comment < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :post, counter_cache: true

  has_many :comment_user_mentions

  validates :body, presence: true, unless: :draft?
  validates :markdown, presence: true, unless: :draft?

  validates_presence_of :user
  validates_presence_of :post

  before_validation :render_markdown_to_body
  before_validation :publish_changes
  after_save :generate_mentions

  attr_accessor :publishing
  alias_method :publishing?, :publishing

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
      CodeCorps::Scenario::GenerateUserMentionsForComment.new(self).call
    end

    def render_markdown_to_body
      return unless markdown_preview_changed?
      html = pipeline.call(markdown_preview)
      self.body_preview = html[:output].to_s
    end

    def publish_changes
      return unless publishing?

      edit if published?
      publish if draft?

      assign_attributes markdown: markdown_preview, body: body_preview
    end

    def pipeline
      @pipeline ||= HTML::Pipeline.new [
        HTML::Pipeline::MarkdownFilter
      ], gfm: true # Github-flavored markdown
    end
end
