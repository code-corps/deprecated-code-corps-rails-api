# == Schema Information
#
# Table name: posts
#
#  id               :integer          not null, primary key
#  status           :string           default("open")
#  post_type        :string           default("task")
#  title            :string           not null
#  body             :text             not null
#  user_id          :integer          not null
#  project_id       :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  post_likes_count :integer          default(0)
#  markdown         :text             not null
#  number           :integer
#  aasm_state       :string
#

class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :status, :post_type, :likes_count, :markdown,
             :number, :state, :created_at, :edited_at, :comments_count

  has_many :comments
  has_many :post_user_mentions
  has_many :comment_user_mentions

  belongs_to :user
  belongs_to :project
end
