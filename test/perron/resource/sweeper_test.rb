# frozen_string_literal: true

require "test_helper"

class Perron::Resource::SweeperTest < ActiveSupport::TestCase
  setup do
    toc_resource_path = "test/dummy/app/content/other/toc-resource.html"
    @resource = Content::Page.new(toc_resource_path)
  end

  test "extracted_headings returns heading texts" do
    headings = @resource.extracted_headings

    assert_equal ["Main Heading", "Section One", "Subsection", "Section Two"], headings
  end

  test "sweeped_content returns sanitized text" do
    content = @resource.sweeped_content

    assert_instance_of String, content
    refute_includes content, "<"
    refute_includes content, ">"
  end
end
