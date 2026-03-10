# frozen_string_literal: true

require "test_helper"

class MarkdownHelperTest < ActionView::TestCase
  include Perron::MarkdownHelper

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
end
