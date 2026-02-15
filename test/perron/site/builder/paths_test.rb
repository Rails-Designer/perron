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

    buildable_post_count = Content::Post.all.select(&:buildable?).count

    assert_equal buildable_post_count, 4
  end

  test "adds nested template paths" do
    @paths_builder.get

    Content::Post.all.select(&:buildable?).each do |post|
      assert_includes @paths, "/blog/#{post.to_param}/template.rb"
    end
  end

  test "adds custom markdown paths" do
    @paths_builder.get

    Content::Author.all.select(&:buildable?).each do |product|
      assert_includes @paths, "/authors/#{product.to_param}.html"
    end
  end
end
