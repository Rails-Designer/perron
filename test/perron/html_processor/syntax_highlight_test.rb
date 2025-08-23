# frozen_string_literal: true

require "test_helper"

class Perron::HtmlProcessor::SyntaxHighlightTest < ActionView::TestCase
  def process_html(html)
    Nokogiri::HTML::DocumentFragment.parse(html).tap { Perron::HtmlProcessor::SyntaxHighlight.new(it).process }
  end

  test "highlights a code block with a specified language" do
    html = '<pre><code class="language-ruby">def hello; "world"; end</code></pre>'
    processed_doc = process_html(html)

    assert_select processed_doc, "div.highlight" do
      assert_select "pre" do
        assert_select "code" do
          assert_select "span.k", text: "def"
          assert_select "span.s2", text: '"world"'
        end
      end
    end
  end

  test "does not process a code block without a language class" do
    html = "<pre><code>This is plain text.</code></pre>"
    processed_doc = process_html(html)

    assert_dom_equal html, processed_doc.to_html
  end

  test "falls back to plain text for an unknown language" do
    html = '<pre><code class="language-foobar">@!#$%^</code></pre>'
    processed_doc = process_html(html)

    assert_select processed_doc, "div.highlight pre code" do |elements|
      assert_equal "@!#$%^", elements.first.text
      assert_select elements.first, "span", count: 0
    end
  end

  test "leaves non-code block content untouched" do
    html = '<h1>Title</h1><p>Some text</p><pre><code class="language-js">const a = 1;</code></pre>'
    processed_doc = process_html(html)

    assert_select processed_doc, "h1", text: "Title"
    assert_select processed_doc, "p", text: "Some text"

    assert_select processed_doc, "div.highlight" do
      assert_select "span.kd", text: "const"
      assert_select "span.nx", text: "a"
      assert_select "span.mi", text: "1"
    end
  end
end
