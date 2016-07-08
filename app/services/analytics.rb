class Analytics
  def initialize(user)
    @user = user
  end

  def track_added_profile_picture_from_facebook
    track_added_profile_picture_from_source("facebook")
  end

  def track_added_profile_picture_from_gravatar
    track_added_profile_picture_from_source("gravatar")
  end

  def track_added_user_category(user_category)
    track(
      event: "Added User Category",
      properties: properties_for_user_category(user_category)
    )
  end

  def track_added_user_role(user_role)
    track(
      event: "Added User Role",
      properties: properties_for_user_role(user_role)
    )
  end

  def track_added_user_skill(user_skill)
    track(
      event: "Added User Skill",
      properties: properties_for_user_skill(user_skill)
    )
  end

  def track_approved_organization_membership(organization_membership)
    track(
      event: "Approved Organization Membership",
      properties: properties_for_organization_membership(organization_membership)
    )
  end

  def track_created_comment(comment)
    track(
      event: "Created Comment",
      properties: properties_for_comment(comment)
    )
  end

  def track_created_comment_image(comment_image)
    track(
      event: "Created Comment Image",
      properties: properties_for_comment_image(comment_image)
    )
  end

  def track_created_organization_membership(organization_membership)
    track(
      event: "Created Organization Membership",
      properties: properties_for_organization_membership(organization_membership)
    )
  end

  def track_created_post(post)
    track(
      event: "Created Post",
      properties: properties_for_post(post)
    )
  end

  def track_created_post_image(post_image)
    track(
      event: "Created Post Image",
      properties: properties_for_post_image(post_image)
    )
  end

  def track_edited_comment(comment)
    track(
      event: "Edited Comment",
      properties: properties_for_comment(comment)
    )
  end

  def track_edited_post(post)
    track(
      event: "Edited Post",
      properties: properties_for_post(post)
    )
  end

  def track_edited_profile
    track(event: "Edited Profile in Onboarding")
  end

  def track_rejected_organization_membership(organization_membership)
    track(
      event: "Rejected Organization Membership",
      properties: properties_for_organization_membership(organization_membership)
    )
  end

  def track_removed_organization_membership(organization_membership)
    track(
      event: "Removed Organization Membership",
      properties: properties_for_organization_membership(organization_membership)
    )
  end

  def track_requested_organization_membership(organization_membership)
    track(
      event: "Requested Organization Membership",
      properties: properties_for_organization_membership(organization_membership)
    )
  end

  def track_removed_user_category(user_category)
    track(
      event: "Removed User Category",
      properties: properties_for_user_category(user_category)
    )
  end

  def track_removed_user_role(user_role)
    track(
      event: "Removed User Role",
      properties: properties_for_user_role(user_role)
    )
  end

  def track_removed_user_skill(user_skill)
    track(
      event: "Removed User Skill",
      properties: properties_for_user_skill(user_skill)
    )
  end

  def track_selected_categories
    track(event: "Selected Categories")
  end

  def track_selected_roles
    track(event: "Selected Roles")
  end

  def track_selected_skills
    track(event: "Selected Skills")
  end

  def track_signed_in_with_email
    track_signed_in_with_source("email")
  end

  def track_signed_in_with_facebook
    track_signed_in_with_source("facebook")
  end

  def track_signed_up_with_email
    track_signed_up_with_source("email")
  end

  def track_signed_up_with_facebook
    track_signed_up_with_source("facebook")
  end

  def track_updated_profile
    track(event: "Updated Profile")
  end

  def track_updated_profile_picture
    track(event: "Updated Profile Picture")
  end

  private

    attr_reader :user

    def identify
      segment.identify(identify_params)
    end

    def identify_params
      {
        user_id: user.id,
        traits: user_traits
      }
    end

    def properties_for_comment(comment)
      {
        comment_id: comment.id,
        post: comment.post.title,
        post_id: comment.post.id,
        post_type: comment.post.post_type,
        project_id: comment.post.project_id,
      }
    end

    def properties_for_comment_image(comment_image)
      {
        comment_id: comment_image.comment.id
      }
    end

    def properties_for_organization_membership(organization_membership)
      {
        organization: organization_membership.organization.name,
        organization_id: organization_membership.organization.id
      }
    end

    def properties_for_post(post)
      {
        post: post.title,
        post_id: post.id,
        post_type: post.post_type,
        project_id: post.project_id,
      }
    end

    def properties_for_post_image(post_image)
      {
        post: post_image.post.title,
        post_id: post_image.post.id
      }
    end

    def properties_for_user_category(user_category)
      {
        category: user_category.category.name,
        category_id: user_category.category.id
      }
    end

    def properties_for_user_role(user_role)
      {
        role: user_role.role.name,
        role_id: user_role.role.id
      }
    end

    def properties_for_user_skill(user_skill)
      {
        skill: user_skill.skill.title,
        skill_id: user_skill.skill.id
      }
    end

    def track(options)
      identify
      segment.track(options.merge(user_id: user.id))
    end

    def track_added_profile_picture_from_source(source)
      track(
        event: "Added Profile Picture",
        source: source
      )
    end

    def track_signed_in_with_source(source)
      track(
        event: "Signed In",
        source: source
      )
    end

    def track_signed_up_with_source(source)
      track(
        event: "Signed Up",
        source: source
      )
    end

    def user_traits
      {
        admin: user.admin,
        biography: user.biography,
        created_at: user.created_at,
        email: user.email,
        facebook_id: user.facebook_id,
        first_name: user.first_name,
        last_name: user.last_name,
        name: user.name,
        state: user.state,
        twitter: user.twitter,
        username: user.username
      }.reject { |_key, value| value.blank? }
    end

    def segment
      @segment ||= Segment::Analytics.new(write_key: segment_write_key, stub: stub_analytics?)
    end

    def segment_write_key
      @segment_write_key ||= (ENV["SEGMENT_WRITE_KEY"] || "")
    end

    def stub_analytics?
      @stub_analytics ||= Rails.env.test? || ENV["SEGMENT_WRITE_KEY"].blank?
    end
end
