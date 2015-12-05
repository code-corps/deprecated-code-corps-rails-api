class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  has_many :comments
  has_many :post_likes

  acts_as_sequenced scope: :project_id, column: :number

  validates_presence_of :project
  validates_presence_of :user
  validates_presence_of :title
  validates_presence_of :body
  validates_presence_of :markdown

  before_validation :render_markdown_to_body

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

  def likes_count
    self.post_likes_count
  end

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
