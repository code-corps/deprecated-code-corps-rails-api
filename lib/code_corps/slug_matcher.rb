class SlugMatcher
  def match?(slug)
    /\A((?:(?:(?:[^-\W]-?))*)(?:(?:(?:[^-\W]-?))*)\w+)\z/ =~ slug ? true : false
  end
end