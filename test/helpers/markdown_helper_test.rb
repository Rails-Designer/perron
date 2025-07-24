# frozen_string_literal: true

require "test_helper"

class MarkdownHelperTest < ActionView::TestCase
  include Perron::MarkdownHelper

  test "passes content and processors correctly through the chain" do
    html = markdownify("<p>Some text.</p>", process: ["dummy_processor"])

    assert_dom_equal '<p class="processed-by-dummy">Some text.</p>', html.strip
  end

  test "renders basic markdown without processors" do
    html = markdownify("## Hello")

    assert_dom_equal "## Hello", html.strip
  end
end
