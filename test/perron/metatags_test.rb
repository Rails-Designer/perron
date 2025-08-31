# frozen_string_literal: true

require "test_helper"
require "perron/metatags"
require "perron/resource"

class Perron::MetatagsTest < ActiveSupport::TestCase
  include ConfigurationHelper

  setup do
    Perron.configure do |config|
      config.metadata.title_suffix = "Helptail"
    end
  end

  test "renders title with suffix when title is different from site name" do
    resource = Content::Post.new("test/dummy/app/content/posts/2023-05-15-sample-post.md")
    metatags = Perron::Metatags.new(resource.metadata).render

    assert_match "<title>Sample Post — Helptail</title>", metatags
  end

  test "renders only the page title when the page title is the same as the suffix" do
    Perron.configuration.metadata.title_suffix = nil

    resource = Content::Post.new("test/dummy/app/content/pages/about.md")
    html = Perron::Metatags.new(resource.metadata).render

    assert_match "<title>About</title>", html
    assert_no_match "—", html
  end

  test "renders title using Rails application name when resource has no title" do
    Perron.configuration.metadata.title_suffix = nil

    resource = Content::Post.new("test/dummy/app/content/pages/root.md")
    html = Perron::Metatags.new(resource.metadata).render

    assert_match "<title>Dummy App</title>", html
    assert_no_match "— Helptail</title>", html
  end

  test "renders og:url using default_url_options and resource path" do
    resource = Content::Post.new("test/dummy/app/content/posts/2023-05-15-sample-post.md")
    html = Perron::Metatags.new(resource.metadata).render

    assert_match "<meta name=\"description\" content=\"Describing sample post\">", html
    assert_match "<meta property=\"og:url\" content=\"http://localhost:3000/blog/sample-post/\">", html
  end
end
