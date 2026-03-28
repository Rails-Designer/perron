# frozen_string_literal: true

require "test_helper"

class MarkdownHelperTest < ActionView::TestCase
  include Perron::MarkdownHelper

  setup do
    @original_default_processors = Perron.configuration.default_processors
  end

  teardown do
    Perron.configure do |config|
      config.default_processors = @original_default_processors
    end
  end

  test "passes content, processors, and resource correctly through the chain" do
    @resource = Content::Post.find!("sample-post")
    html = markdownify("<p>Some text.</p>", process: ["dummy_processor"])

    expected_class = @resource.metadata.dig("processor_class") || "processed-by-dummy"
    assert_dom_equal %(<p class="#{expected_class}">Some text.</p>), html.strip
  end

  test "uses explicit resource parameter when provided" do
    resource = Content::Post.find!("another-post")
    html = markdownify("<p>Some text.</p>", process: ["dummy_processor"], resource: resource)

    expected_class = resource.metadata.dig("processor_class") || "processed-by-dummy"
    assert_dom_equal %(<p class="#{expected_class}">Some text.</p>), html.strip
  end

  test "renders basic markdown without processors" do
    html = markdownify("## Hello")

    assert_dom_equal "## Hello", html.strip
  end

  test "uses default_processors from config when none passed" do
    Perron.configure do |config|
      config.default_processors = %w[dummy_processor]
    end

    @resource = Content::Post.find!("sample-post")
    html = markdownify("<p>Some text.</p>")

    expected_class = @resource.metadata.dig("processor_class") || "processed-by-dummy"
    assert_dom_equal %(<p class="#{expected_class}">Some text.</p>), html.strip
  end

  test "uses default_processors from config when empty array passed" do
    Perron.configure do |config|
      config.default_processors = %w[dummy_processor]
    end

    @resource = Content::Post.find!("sample-post")
    html = markdownify("<p>Some text.</p>", process: [])

    expected_class = @resource.metadata.dig("processor_class") || "processed-by-dummy"
    assert_dom_equal %(<p class="#{expected_class}">Some text.</p>), html.strip
  end

  test "explicit process argument overrides default_processors" do
    Perron.configure do |config|
      config.default_processors = %w[target_blank]
    end

    html = markdownify('<a href="http://example.com">Link</a><img src="test.jpg">', process: ["lazy_load_images"])

    assert_includes html, 'loading="lazy"'
    refute_includes html, 'target="_blank"'
  end

  test "default_processors defaults to empty array" do
    assert_equal [], Perron.configuration.default_processors
  end
end
