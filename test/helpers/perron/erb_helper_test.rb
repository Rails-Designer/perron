require "test_helper"

class ErbHelperTest < ActionView::TestCase
  include Perron::ErbHelper

  setup { @resource = Content::Page.new("test/dummy/app/content/pages/about.md") }

  test "erbify processes a string with access to @resource" do
    content_string = "Page Title: <%= @resource.metadata.title %>"
    html = erbify(content_string)

    assert_equal "Page Title: About", html.strip
  end
end
