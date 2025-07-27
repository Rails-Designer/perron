# frozen_string_literal: true

require "test_helper"
require "perron/html_processor"
require "perron/errors"

# Changed ActiveSupport::TestCase to ActionView::TestCase to access DOM assertions.
class HtmlProcessorTest < ActionView::TestCase
  test "applies a custom processor specified by a string" do
    html_input = "<p>Some text.</p>"
    processed_html = Perron::HtmlProcessor.new(html_input, processors: ["dummy_processor"]).process

    assert_dom_equal '<p class="processed-by-dummy">Some text.</p>', processed_html
  end

  test "applies a built-in processor specified by a string" do
    html_input = '<a href="https://example.com">Link</a>'
    processed_html = Perron::HtmlProcessor.new(html_input, processors: ["target_blank"]).process

    assert_dom_equal '<a href="https://example.com" target="_blank">Link</a>', processed_html
  end
end
