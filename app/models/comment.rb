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
        html = parser.render(markdown)
        self.body = html
      end
    end

    def parser
      @parser ||= Redcarpet::Markdown.new(renderer, extensions = {})
    end

    def renderer
      @renderer ||= Redcarpet::Render::HTML.new(render_options = {})
    end
end
