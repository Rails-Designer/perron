# frozen_string_literal: true

require "test_helper"

class Perron::Resource::SearchableTest < ActiveSupport::TestCase
  class TestResource < Perron::Resource
    search_fields :category, :author
  end

  class AnotherResource < Perron::Resource
  end

  test "search_fields sets search_fields_list" do
    assert_equal [:category, :author], TestResource.search_fields_list
  end

  test "search_fields_list defaults to empty array" do
    assert_equal [], AnotherResource.search_fields_list
  end

  test "search_fields_list is independent per class" do
    assert_equal [:category, :author], TestResource.search_fields_list
    assert_equal [], AnotherResource.search_fields_list
  end
end
