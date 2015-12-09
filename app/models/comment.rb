require 'html/pipeline'
require 'code_corps/scenario/generate_user_mentions_for_comment'

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  has_many :comment_user_mentions

  validates_presence_of :body
  validates_presence_of :markdown
  validates_presence_of :user
  validates_presence_of :post

  before_validation :render_markdown_to_body

  after_save :generate_mentions # Still safe because it runs inside transaction

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
