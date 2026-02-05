# frozen_string_literal: true

require "test_helper"

class MetaTagsHelperTest < ActionView::TestCase
  include Perron::MetaTagsHelper

  test "meta_tags returns a truthy value" do
    def request.path; "/test-path"; end

    result = meta_tags
    assert result, "Expected meta_tags to return a truthy value"
  end
end
