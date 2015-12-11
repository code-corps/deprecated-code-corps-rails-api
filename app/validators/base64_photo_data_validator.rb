require 'code_corps/base64_image_matcher'

class Base64PhotoDataValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    return validate_property(record, attribute, value)
  end

  private

    def validate_property(record, attribute, value)
      unless valid_base64_image_string?(value)
        record.errors[attribute] = "must be a valid data URI for a jpeg, png, or gif image"
      end
    end

    def valid_base64_image_string?(base64_image_string)
      base64_image_matcher.match?(base64_image_string)
    end

    def base64_image_matcher
      @base64_image_matcher ||= Base64ImageMatcher.new
    end
end
