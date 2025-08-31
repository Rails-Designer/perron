# frozen_string_literal: true

require "test_helper"

class Perron::HtmlProcessor::TargetBlankTest < ActionView::TestCase
  def process_html(html)
    document = Nokogiri::HTML::DocumentFragment.parse(html)

    Perron::HtmlProcessor::TargetBlank.new(document).process

    document.to_html
  end

  test "adds target=_blank to external links" do
    html = '<a href="https://example.com">External</a>'
    processed = process_html(html)

    assert_dom_equal '<a href="https://example.com" target="_blank">External</a>', processed
  end

  test "does not add target=_blank to internal links" do
    html = '<a href="/some/page">Internal</a>'
    processed = process_html(html)

    assert_dom_equal html, processed
  end

  test "does not add target=_blank to anchor links" do
    html = '<a href="#section">Anchor</a>'
    processed = process_html(html)

    assert_dom_equal html, processed
  end
end
