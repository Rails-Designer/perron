module GitHubHelper
  def view_on_github_url(path, branch: "main")
    username = ENV.fetch("GITHUB_USERNAME", "Rails-Designer")
    repository = ENV.fetch("GITHUB_REPOSITORY", "perron-site")

    "https://github.com/#{username}/#{repository}/blob/#{branch}/#{path}"
  end
end
