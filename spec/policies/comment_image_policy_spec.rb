require "rails_helper"

describe CommentImagePolicy do
  subject { described_class }

  let(:comment) { build_stubbed(:comment) }

  let(:gif_string) do
    open(
      File.open(
        "#{Rails.root}/spec/sample_data/base64_images/gif.txt", "r"
      ),
      &:read
    )
  end

  let(:comment_image) do
    build_stubbed(
      :comment_image,
      :with_s3_image,
      filename: "jake.gif",
      base64_photo_data: gif_string,
      comment: comment,
      user: user
    )
  end

  let(:user) { build_stubbed(:user) }

  permissions :create? do
    it "is not permitted when no user is present" do
      expect(subject).not_to permit(nil, comment_image)
    end

    it "is not permitted when not the same user" do
      expect(subject).not_to permit(user, comment_image)
    end

    it "is permitted when comment belongs to the user" do
      expect(subject).to permit(comment.user, comment_image)
    end
  end
end
