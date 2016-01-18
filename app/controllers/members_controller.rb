# == Schema Information
#
# Table name: members
#
#  id         :integer          not null, primary key
#  slug       :string           not null
#  model_id   :integer
#  model_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MembersController < ApplicationController

  def show
    member = Member.includes(model: :members).find_by_slug!(member_slug)

    authorize member

    render json: member, include: ['model']
  end

  def member_slug
    params[:id]
  end

end
