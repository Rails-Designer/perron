# frozen_string_literal: true

require "test_helper"

class Perron::Site::Builder::FeedsTest < ActiveSupport::TestCase
  include ConfigurationHelper

  setup do
    @output_path = Rails.root.join("output")

    FileUtils.rm_rf(@output_path)
    FileUtils.mkdir_p(@output_path)
  end

  teardown do
    FileUtils.rm_rf(@output_path)
  end

  test "does not instantiate any builders if feeds are disabled" do
    Content::Post.configure { |it| it.feeds.rss.enabled = false; it.feeds.json.enabled = false }

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
end
