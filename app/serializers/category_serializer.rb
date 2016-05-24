# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  slug        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#

class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :description
end
