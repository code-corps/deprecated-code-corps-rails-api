# == Schema Information
#
# Table name: previews
#
#  id         :integer          not null, primary key
#  body       :text             not null
#  markdown   :text             not null
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "html/pipeline"
require "html/pipeline/rouge_filter"
require "code_corps/scenario/generate_preview_mentions"

class Preview < ActiveRecord::Base
  belongs_to :user

  has_many :preview_user_mentions

  validates :body, presence: true
  validates :markdown, presence: true
  validates :user, presence: true

  before_validation :render_markdown_to_body

  after_save :generate_mentions

  private

    def generate_mentions
      CodeCorps::Scenario::GeneratePreviewMentions.new(self).call
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
end
