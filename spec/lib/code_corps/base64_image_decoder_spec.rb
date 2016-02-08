require "rails_helper"
require "code_corps/base64_image_decoder"

module CodeCorps
  describe Base64ImageDecoder do
    describe ".decode" do
      let(:project) { create(:project) }

      context "when base64 string has data string" do
        before do
          filename = "#{Rails.root}/spec/sample_data/base64_images/jpeg.txt"
          base64_string = File.open(filename, &:read)
          @result = Base64ImageDecoder.new(base64_string).decode
        end

        it "sets the right content type and filename" do
          expect(@result.content_type).to eq "image/png"
          expect(@result.original_filename).to include ".png"
        end

        it "returns valid image data for Paperclip" do
          project.icon = @result
          expect(project).to be_valid
        end
      end

      context "when base64 string has no data string" do
        before do
          filename = "#{Rails.root}/spec/sample_data/base64_images/jpeg_without_data_string.txt"
          base64_string = File.open(filename, &:read)
          @result = Base64ImageDecoder.new(base64_string).decode
        end

        it "sets the right content type and filename" do
          expect(@result.content_type).to eq "image/png"
          expect(@result.original_filename).to include ".png"
        end

        it "returns valid image data for Paperclip" do
          project.icon = @result
          expect(project).to be_valid
        end
      end
    end
  end
end