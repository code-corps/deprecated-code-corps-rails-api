require "rails_helper"
require "base64_photo_data_validator"

describe "Base64PhotoDataValidator" do
  context "when the record is a PostImage" do
    context "when base64 string has data string" do
      it "returns nil" do
        file = File.open("#{Rails.root}/spec/sample_data/base64_images/jpeg.txt", "r")
        jpeg_string = open(file, &:read)
        post_image = PostImage.new(base64_photo_data: jpeg_string)
        expect(Base64PhotoDataValidator.new({attributes: :base64_photo_data}).validate_each(post_image, :base64_photo_data, post_image.base64_photo_data)).to be_nil
      end

      context "when base64 string has no data string" do
        it "returns the error text" do
          file = File.open("#{Rails.root}/spec/sample_data/base64_images/jpeg_without_data_string.txt", "r")
          jpeg_without_data_string = open(file, &:read)
          post_image = PostImage.new(base64_photo_data: jpeg_without_data_string)
          expect(Base64PhotoDataValidator.new({attributes: :base64_photo_data}).validate_each(post_image, :base64_photo_data, post_image.base64_photo_data)).to eq "must be a valid data URI for a jpeg, png, or gif image"
        end
      end
    end
  end
end
