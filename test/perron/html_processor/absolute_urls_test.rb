# frozen_string_literal: true

require 'test_helper'

class Perron::HtmlProcessor::AbsoluteUrlsTest < ActionView::TestCase
  def process_html(html)
    document = Nokogiri::HTML::DocumentFragment.parse(html)

    Perron::HtmlProcessor::AbsoluteUrls.new(document).process

    document.to_html
  end

  test 'converts relative image src to absolute URL' do
    html = '<img src="/images/photo.jpg" alt="A photo">'
    processed = process_html(html)

    assert_dom_equal '<img src="http://localhost:3000/images/photo.jpg" alt="A photo">', processed
  end

  test 'does not modify already absolute http URL' do
    html = '<img src="http://example.com/images/photo.jpg" alt="A photo">'
    processed = process_html(html)

    assert_dom_equal html, processed
  end

  test 'does not modify already absolute https URL' do
    html = '<img src="https://example.com/images/photo.jpg" alt="A photo">'
    processed = process_html(html)

    assert_dom_equal html, processed
  end

  test 'does not modify protocol-relative URL' do
    html = '<img src="//example.com/images/photo.jpg" alt="A photo">'
    processed = process_html(html)

    assert_dom_equal html, processed
  end

  test 'does not modify image without src attribute' do
    html = '<img alt="A photo">'
    processed = process_html(html)

    assert_dom_equal html, processed
  end

  test 'processes multiple images' do
    html = '<img src="/images/photo1.jpg"><img src="/images/photo2.jpg">'
    processed = process_html(html)

    assert_dom_equal '<img src="http://localhost:3000/images/photo1.jpg"><img src="http://localhost:3000/images/photo2.jpg">',
                     processed
  end

  test 'does not affect content without images' do
    html = '<p>Some text, but no images.</p>'
    processed = process_html(html)

    assert_dom_equal html, processed
  end
end
