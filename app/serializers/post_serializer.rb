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
#

class PostSerializer < ActiveModel::Serializer
  attributes :id, :number, :post_type, :state, :status,
             :title, :body, :markdown, :likes_count, :comments_count,
             :created_at, :edited_at

  has_many :comments
  has_many :post_user_mentions
  has_many :comment_user_mentions

  belongs_to :user
  belongs_to :project

  def likes_count
    object.post_likes_count
  end
end
