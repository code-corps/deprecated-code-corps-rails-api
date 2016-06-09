# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  email                 :string           not null
#  encrypted_password    :string(128)      not null
#  confirmation_token    :string(128)
#  remember_token        :string(128)      not null
#  username              :string
#  admin                 :boolean          default(FALSE), not null
#  website               :text
#  twitter               :string
#  biography             :text
#  facebook_id           :string
#  facebook_access_token :string
#  base64_photo_data     :string
#  photo_file_name       :string
#  photo_content_type    :string
#  photo_file_size       :integer
#  photo_updated_at      :datetime
#  name                  :text
#  aasm_state            :string           default("signed_up"), not null
#

class UsersController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:show_authenticated_user,
                                               :update,
                                               :update_authenticated_user]

  skip_before_action do
    load_and_authorize_resource param_method: :reset_password_params, only: [:reset_password]
  end

  def create
    if creating_with_facebook?
      create_user_from_facebook_and_render_json
    else
      create_user_with_email_and_render_json
    end
  end

  def show
    user = User.includes(skills: :roles).find(params[:id])

    authorize user
    render json: user, include: ["skills"]
  end

  def update
    user = User.find(params[:id])

    authorize user

    update_and_render_result user
  end

  def show_authenticated_user
    render json: current_user, serializer: UserSerializer
  end

  def update_authenticated_user
    update_and_render_result current_user
  end

  def forgot_password
    authorize User

    user = User.find_by(email: forgot_password_params[:email])

    if user && user.forgot_password!
      render json: user
    else
      render_no_such_email_error
    end
  end

  def reset_password
    user = find_user_by_confirmation_token

    authorize User

    if user && user.update_password(reset_password_params[:password])
      render json: user
    else
      render_could_not_reset_password_error
    end
  end

  private

    def update_and_render_result(record)
      record.assign_attributes update_params

      if record.save
        UpdateProfilePictureWorker.perform_async(record.id) if photo_param?
        render json: record
      else
        render_validation_errors(record.errors)
      end
    end

    def forgot_password_params
      parse_params(params, only: [:email])
    end

    def reset_password_params
      parse_params(params, only: [:confirmation_token, :password])
    end

    def create_params
      parse_params(params, only: [:email, :username, :password, :facebook_id,
                                  :facebook_access_token, :base64_photo_data])
    end

    def update_params
      parse_params(params, only: [:name, :website, :biography, :twitter,
                                  :base64_photo_data, :state_transition])
    end

    def render_no_such_email_error
      render_custom_validation_errors :email, "doesn't exist in the database"
    end

    def render_could_not_reset_password_error
      render_custom_validation_errors :password, "couldn't be reset"
    end

    def render_custom_validation_errors(field, message)
      errors = ActiveModel::Errors.new(User.new)
      errors.add field, message
      render_error errors
    end

    def find_user_by_confirmation_token
      User.find_by(confirmation_token: reset_password_params[:confirmation_token])
    end

    def creating_with_facebook?
      create_params[:facebook_id].present? && create_params[:facebook_access_token].present?
    end

    def create_user_from_facebook_and_render_json
      user = User.where(
        "facebook_id = ? OR email = ?",
        create_params[:facebook_id],
        create_params[:email]
      ).first_or_create

      user.update(create_params)

      if user.save
        AddFacebookFriendsWorker.perform_async(user.id)
        if photo_param?
          UpdateProfilePictureWorker.perform_async(user.id)
        else
          AddFacebookProfilePictureWorker.perform_async(user.id)
        end

        render json: user
      else
        render_validation_errors(user.errors)
      end
    end

    def create_user_with_email_and_render_json
      user = User.new(create_params)

      if user.save
        if photo_param?
          UpdateProfilePictureWorker.perform_async(user.id)
        else
          AddProfilePictureFromGravatarWorker.perform_async(user.id)
        end

        render json: user
      else
        render_validation_errors user.errors
      end
    end

    def photo_param?
      update_params[:base64_photo_data].present? ||
        create_params[:base64_photo_data].present?
    end
end
