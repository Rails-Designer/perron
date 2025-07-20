# frozen_string_literal: true

require "test_helper"
require "perron/metatags"
require "perron/site/resource"

class MetatagsTest < ActiveSupport::TestCase
  setup do
    Perron.configure do |config|
      config.metadata.title_suffix = "AppRefresher"
    end
  end

  test "renders title with suffix when title is different from site name" do
    resource = Perron::Resource.new("test/dummy/app/content/posts/2023-05-15-sample-post.md")
    metatags = Perron::Metatags.new(resource).render

    assert_match "<title>Sample Post — AppRefresher</title>", metatags
  end

  test "renders only the page title when the page title is the same as the suffix" do
    Perron.configuration.metadata.title_suffix = nil

    resource = Perron::Resource.new("test/dummy/app/content/pages/about.md")
    html = Perron::Metatags.new(resource).render

    assert_match "<title>About</title>", html
    assert_no_match "—", html
  end

  test "renders title using Rails application name when resource has no title" do
    Perron.configuration.metadata.title_suffix = nil

    resource = Perron::Resource.new("test/dummy/app/content/pages/root.md")
    html = Perron::Metatags.new(resource).render

    assert_match "<title>AppRefresher</title>", html
    assert_no_match "— AppRefresher</title>", html
  end

  test "renders og:url using default_url_options and resource path" do
    resource = Perron::Resource.new("test/dummy/app/content/posts/2023-05-15-sample-post.md")
    html = Perron::Metatags.new(resource).render

    assert_match "<meta name=\"description\" content=\"Describing sample post\">", html
    assert_match "<meta property=\"og:url\" content=\"http://localhost:3000/sample-post/\">", html
  end
end
