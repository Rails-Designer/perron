# frozen_string_literal: true

require "test_helper"

class MetaTagsHelperTest < ActionView::TestCase
  include Perron::MetaTagsHelper

  test "meta_tags returns a truthy value" do
    def request.path; "/test-path"; end

    result = meta_tags
    assert result, "Expected meta_tags to return a truthy value"
  end

  test "@metadata from controller is overridden by frontmatter" do
    def request.path; "/test-path"; end

    post = Content::Post.new("test/dummy/app/content/posts/2023-05-15-sample-post.md")

    @resource = post
    @metadata = { title: "Controller Override" }

    html = meta_tags

    assert_includes html, "<title>Sample Post", "Frontmatter title should win over @metadata"
    refute_includes html, "Controller Override", "@metadata title should not appear"
  end
end
