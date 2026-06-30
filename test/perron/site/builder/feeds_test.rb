# frozen_string_literal: true

require "test_helper"

class Perron::Site::Builder::FeedsTest < ActiveSupport::TestCase
  include ConfigurationHelper

  setup do
    @output_path = Rails.root.join("output")

    FileUtils.rm_rf(@output_path)
    FileUtils.mkdir_p(@output_path)

    Content::Post.configure do |config|
      config.feeds.rss.enabled = false
      config.feeds.atom.enabled = false
      config.feeds.json.enabled = false
    end
  end

  teardown do
    FileUtils.rm_rf(@output_path)

    %w[rss.erb atom.erb json.erb].each do |file|
      path = Rails.root.join("app/views/content/posts/#{file}")

      FileUtils.rm_f(path)
    end

    Content::Post.configure do |config|
      config.feeds.rss.enabled = false
      config.feeds.atom.enabled = false
      config.feeds.json.enabled = false

      config.feeds.atom.path = "feeds/posts.atom"

      config.feeds.atom[:split_by] = nil
      config.feeds.rss[:split_by] = nil
      config.feeds.json[:split_by] = nil
    end
  end

  test "does not instantiate any builders if feeds are disabled" do
    Content::Post.configure do |it|
      it.feeds.rss.enabled = false
      it.feeds.json.enabled = false
    end

    rss_never_called = -> { flunk "Rss.new should not have been called" }
    json_never_called = -> { flunk "Json.new should not have been called" }

    Perron::Site::Builder::Feeds::Rss.stub :new, rss_never_called do
      Perron::Site::Builder::Feeds::Json.stub :new, json_never_called do
        Perron::Site::Builder::Feeds.new(@output_path).generate
      end
    end

    assert_empty Dir.glob("#{@output_path}/**/*")
  end

  test "writes content from Rss to the default path" do
    Content::Post.configure do |config|
      config.feeds.rss.enabled = true
      config.feeds.json.enabled = false
    end

    rss_builder_stub = Minitest::Mock.new
    rss_builder_stub.expect :generate, "rss content from stub"

    Perron::Site::Builder::Feeds::Rss.stub :new, rss_builder_stub do
      Perron::Site::Builder::Feeds.new(@output_path).generate
    end

    expected_file = @output_path.join("feeds/posts.xml")

    assert File.exist?(expected_file), "Expected file '#{expected_file}' to exist."
    assert_equal "rss content from stub", File.read(expected_file)

    rss_builder_stub.verify
  end

  test "writes content from Json to a custom path" do
    Content::Post.configure do |config|
      config.feeds.rss.enabled = false
      config.feeds.json.enabled = true
      config.feeds.json.path = "api/articles.json"
    end

    json_builder_stub = Minitest::Mock.new

    json_builder_stub.expect :generate, "json content from stub"

    Perron::Site::Builder::Feeds::Json.stub :new, json_builder_stub do
      Perron::Site::Builder::Feeds.new(@output_path).generate
    end

    expected_file = @output_path.join("api/articles.json")

    assert File.exist?(expected_file), "Expected file '#{expected_file}' to exist."
    assert_equal "json content from stub", File.read(expected_file)

    json_builder_stub.verify
  end

  test "uses custom RSS template when present" do
    posts = Perron::Site.collection("posts")

    posts.configuration.feeds.rss.enabled = true
    posts.configuration.feeds.rss.path = "feeds/posts.xml"

    File.write(Rails.root.join("app/views/content/posts/rss.erb"), "Custom RSS: <%= resources.map(&:id).join(',') %>")

    rss = Perron::Site::Builder::Feeds::Rss.new(collection: posts)
    output = rss.generate

    assert output.start_with?("Custom RSS: ")
  end

  test "uses custom Atom template when present" do
    posts = Perron::Site.collection("posts")

    posts.configuration.feeds.atom.enabled = true
    posts.configuration.feeds.atom.path = "feeds/posts.atom"

    File.write(Rails.root.join("app/views/content/posts/atom.erb"), "Custom Atom: <%= resources.count %>")

    atom = Perron::Site::Builder::Feeds::Atom.new(collection: posts)
    output = atom.generate

    assert_equal "Custom Atom: 4", output
  end

  test "uses custom JSON template when present" do
    posts = Perron::Site.collection("posts")

    posts.configuration.feeds.json.enabled = true
    posts.configuration.feeds.json.path = "feeds/posts.json"

    File.write(Rails.root.join("app/views/content/posts/json.erb"), '{"custom": true, "items": <%= resources.count %>}')

    json = Perron::Site::Builder::Feeds::Json.new(collection: posts)
    output = json.generate

    assert_equal '{"custom": true, "items": 4}', output
  end

  test "template has access to collection, resources, and config" do
    posts = Perron::Site.collection("posts")

    posts.configuration.feeds.rss.enabled = true

    File.write(
      Rails.root.join("app/views/content/posts/rss.erb"),
      "<%= collection.name %>:<%= resources.count %>:<%= config.title || 'default' %>"
    )

    rss = Perron::Site::Builder::Feeds::Rss.new(collection: posts)
    output = rss.generate

    assert_equal "posts:4:default", output
  end

  test "generates split feeds grouped by metadata field" do
    Content::Post.configure do |config|
      config.feeds.atom.enabled = true
      config.feeds.atom.path = "feeds/posts.atom"
      config.feeds.atom.split_by :category
    end

    File.write(Rails.root.join("app/views/content/posts/atom.erb"), "<%= resources.count %>")

    Perron::Site::Builder::Feeds.new(@output_path).generate

    main_feed = @output_path.join("feeds/posts.atom")
    news_feed = @output_path.join("feeds/posts/category/news.atom")
    tutorial_feed = @output_path.join("feeds/posts/category/tutorial.atom")

    assert File.exist?(main_feed)
    assert_equal "4", File.read(main_feed)

    assert File.exist?(news_feed)
    assert_equal "1", File.read(news_feed)

    assert File.exist?(tutorial_feed)
    assert_equal "1", File.read(tutorial_feed)
  end

  test "split feed uses custom path template when provided" do
    Content::Post.configure do |config|
      config.feeds.atom.enabled = true
      config.feeds.atom.path = "feeds/posts.atom"

      config.feeds.atom.split_by :category, path: "feeds/by-cat/:value.atom"
    end

    File.write(Rails.root.join("app/views/content/posts/atom.erb"), "<%= config.path %>")

    Perron::Site::Builder::Feeds.new(@output_path).generate

    news_feed = @output_path.join("feeds/by-cat/news.atom")
    tutorial_feed = @output_path.join("feeds/by-cat/tutorial.atom")

    assert File.exist?(news_feed), "News split feed at custom path should exist"
    assert File.exist?(tutorial_feed), "Tutorial split feed at custom path should exist"
    assert_equal "feeds/by-cat/news.atom", File.read(news_feed)
    assert_equal "feeds/by-cat/tutorial.atom", File.read(tutorial_feed)
  end

  test "split feed does not create files for resources without the split field" do
    Content::Post.configure do |config|
      config.feeds.atom.enabled = true
      config.feeds.atom.path = "feeds/posts.atom"

      config.feeds.atom.split_by :category
    end

    Perron::Site::Builder::Feeds.new(@output_path).generate

    feeds_dir = @output_path.join("feeds/posts/category")
    generated_categories = Dir.glob("#{feeds_dir}/*.atom").map { |f| File.basename(f, ".atom") }

    assert_includes generated_categories, "news"
    assert_includes generated_categories, "tutorial"
    refute_includes generated_categories, "custom"
  end

  test "falls back to default generation when no custom template exists" do
    posts = Perron::Site.collection('posts')

    posts.configuration.feeds.rss.enabled = true

    rss = Perron::Site::Builder::Feeds::Rss.new(collection: posts)
    output = rss.generate

    assert output.start_with?("<?xml"), "Should generate XML when no custom template"
  end

  test "Atom feed renders URLs as actual URLs, not method signatures" do
    posts = Perron::Site.collection("posts")

    posts.configuration.feeds.atom.enabled = true
    posts.configuration.feeds.atom.path = "feed.atom"

    atom = Perron::Site::Builder::Feeds::Atom.new(collection: posts)
    output = atom.generate

    refute_includes output, "#<Method:", "Should not contain method signatures"
    refute_includes output, "current_feed_url", "Should not contain method name in output"
    assert_includes output, "http://", "Should contain actual URL"
  end

  test "Atom feed id and self link contain actual feed URL" do
    posts = Perron::Site.collection("posts")

    posts.configuration.feeds.atom.enabled = true
    posts.configuration.feeds.atom.path = "feed.atom"

    atom = Perron::Site::Builder::Feeds::Atom.new(collection: posts)
    output = atom.generate

    feed_url = "http://localhost:3000/feed.atom"

    assert_match(/<id>#{Regexp.escape(feed_url)}<\/id>/, output, "Feed id should contain actual URL")
    assert_match(/<link href="#{Regexp.escape(feed_url)}"[^>]*rel="self"/, output, "Self link should contain actual URL")
  end
end
