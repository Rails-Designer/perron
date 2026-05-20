# frozen_string_literal: true

require "test_helper"
require "perron/html_processor"
require "perron/errors"

class Perron::HtmlProcessorTest < ActionView::TestCase
  test "applies a custom processor with resource data" do
    resource = Content::Post.find!("sample-post")
    html_input = "<p>Some text.</p>"
    processed_html = Perron::HtmlProcessor.new(html_input, processors: ["dummy_processor"], resource: resource).process

    assert_dom_equal '<p class="custom-from-metadata">Some text.</p>', processed_html
  end

  test "applies a built-in processor specified by a string" do
    html_input = '<a href="https://example.com">Link</a>'
    processed_html = Perron::HtmlProcessor.new(html_input, processors: ["target_blank"]).process

    assert_dom_equal '<a href="https://example.com" target="_blank">Link</a>', processed_html
  end
end
