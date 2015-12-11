require 'rails_helper'
require 'code_corps/base64_image_matcher'

module CodeCorps
  describe Base64ImageMatcher do
    let(:base64_image_matcher) { Base64ImageMatcher.new }

    describe "#match" do
      context 'when base64 string has data string' do
        it 'matches gifs' do
          file = File.open("#{Rails.root}/spec/sample_data/base64_images/gif.txt", 'r')
          gif_string = open(file) { |io| io.read }
          expect(base64_image_matcher.match?(gif_string)).to eq true
        end

        it 'matches jpegs' do
          file = File.open("#{Rails.root}/spec/sample_data/base64_images/jpeg.txt", 'r')
          jpeg_string = open(file) { |io| io.read }
          expect(base64_image_matcher.match?(jpeg_string)).to eq true
        end

        it 'matches pngs' do
          file = File.open("#{Rails.root}/spec/sample_data/base64_images/png.txt", 'r')
          png_string = open(file) { |io| io.read }
          expect(base64_image_matcher.match?(png_string)).to eq true
        end
      end

      context 'when base64 string has no data string' do
        it 'does not match' do
          file = File.open("#{Rails.root}/spec/sample_data/base64_images/jpeg_without_data_string.txt", 'r')
          gif_string = open(file) { |io| io.read }
          expect(base64_image_matcher.match?(gif_string)).to eq false
        end
      end
    end
  end
end