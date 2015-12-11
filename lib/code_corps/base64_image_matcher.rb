class Base64ImageMatcher
  BASE64_REGEX = /^data:image\/(png|jpg|gif|jpeg|pjpeg|x-png);base64,(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=)?$/

  def match?(base64_string)
    BASE64_REGEX =~ base64_string ? true : false
  end
end