require 'html/pipeline'

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  validates_presence_of :body
  validates_presence_of :markdown
  validates_presence_of :user
  validates_presence_of :post

  before_validation :render_markdown_to_body

  private

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
