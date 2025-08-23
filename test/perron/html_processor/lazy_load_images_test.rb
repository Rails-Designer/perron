# frozen_string_literal: true

require "test_helper"
require "perron/html_processor/lazy_load_images"

class Perron::HtmlProcessor::LazyLoadImagesTest < ActionView::TestCase
  def process_html(html)
    document = Nokogiri::HTML::DocumentFragment.parse(html)

    Perron::HtmlProcessor::LazyLoadImages.new(document).process

    document.to_html
  end

  test "adds loading=lazy to an image tag" do
    html = '<img src="photo.jpg" alt="A photo">'
    processed = process_html(html)

    assert_dom_equal '<img src="photo.jpg" alt="A photo" loading="lazy">', processed
  end

  test "does not affect content without images" do
    html = "<p>Some text, but no images.</p>"
    processed = process_html(html)

    assert_dom_equal html, processed
  end
end
