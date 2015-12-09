module CodeCorps
  class GithubRepositoryUrlParser
    def initialize(url)
      @url = url
    end

    def owner_name
      return unless @url.present?

      owner_name = @url.split("/")[-2]

      possible_prefix = "git@github.com:"
      owner_name.sub!(possible_prefix,"")

      owner_name
    end

    def repository_name
      return unless @url.present?

      repo_name_with_extension = @url.split("/").last
      repo_name_without_extension = repo_name_with_extension.sub(".git", "")

      repo_name_without_extension
    end

    def slug
      "#{organization}/#{name}"
    end
  end
end
