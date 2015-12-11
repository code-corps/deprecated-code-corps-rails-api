class UsersController < ApplicationController

  before_action :doorkeeper_authorize!, only: [:show_authenticated_user, :update, :update_authenticated_user]

  skip_before_action do
    load_and_authorize_resource param_method: :reset_password_params, only: [:reset_password]
  end

  def create
    user = User.new(create_params)

    if creating_with_facebook?
      create_user_from_facebook_and_render_json
    else
      create_user_with_email_and_render_json
    end
  end

  def show
    user = User.includes(skills: [:skill_category]).find(params[:id])

    authorize user
    render json: user, include: ["skills"]
  end

  def update
    user = User.find(params[:id])

    authorize user

    update_and_render_result user
  end

  def show_authenticated_user
    render json: current_user, serializer: AuthenticatedUserSerializer
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
        render json: record
      else
        render_validation_errors(record.errors)
      end
    end

    def forgot_password_params
      record_attributes.permit(:email)
    end

    def reset_password_params
      record_attributes.permit(:confirmation_token, :password)
    end

    def create_params
      record_attributes.permit(:email, :username, :password, :facebook_id, :facebook_access_token, :base_64_photo_data)
    end

    def update_params
      record_attributes.permit(:website, :biography, :twitter)
    end

    def render_no_such_email_error
      render_custom_validation_errors :email, "doesn't exist in the database"
    end

    def render_could_not_reset_password_error
      render_custom_validation_errors :password, "couldn't be reset"
    end

    def render_custom_validation_errors field, message
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
      user = User.where("facebook_id = ? OR email = ?", create_params[:facebook_id], create_params[:email]).first_or_create

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
        end

        render json: user
      else
        render_validation_errors user.errors
      end
    end

    def photo_param?
      create_params[:base_64_photo_data].present?
    end
end
