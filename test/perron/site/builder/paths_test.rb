require "test_helper"

class Perron::Site::Builder::PathsTest < ActiveSupport::TestCase
  setup do
    @paths = Set.new
    @paths_builder = Perron::Site::Builder::Paths.new(@paths)
  end

  test "adds index paths for content controllers" do
    @paths_builder.get

    assert_includes @paths, "/blog"
    assert_includes @paths, "/"
  end

  test "adds show paths for buildable posts" do
    @paths_builder.get

    expected_post_paths = Content::Post.all.select(&:buildable?).map { "/blog/#{it.to_param}" }
    expected_post_paths.each { assert_includes @paths, it }
  end

  test "excludes non-content controller routes" do
    @paths_builder.get

    refute @paths.any? { it.include?("/search") }
  end

  test "only includes buildable resources" do
    @paths_builder.get

    assert_equal Content::Post.all.select(&:buildable?).count, 4
  end

  test "adds nested template paths" do
    @paths_builder.get

    assert_includes @paths, "/blog/sample-post/template.rb"
    assert_includes @paths, "/blog/another-post/template.rb"
    assert_includes @paths, "/blog/no-author/template.rb"
  end

  test "adds custom markdown paths" do
    @paths_builder.get

    assert_includes @paths, "/authors/rails-designer.html"
    assert_includes @paths, "/authors/not-rails-designer.html"
  end

  test "adds constraint-based category paths" do
    @paths_builder.get

    assert_includes @paths, "/blog/ruby"
    assert_includes @paths, "/blog/rails"
    assert_includes @paths, "/blog/css"
  end

  test "uses collection_name when controller overrides default mapping" do
    @paths_builder.get

    assert_includes @paths, "/team", "Should include page resource"
    assert_includes @paths, "/team/about", "Should include page resource"
  end
end
