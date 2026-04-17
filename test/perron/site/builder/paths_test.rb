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

  test "generates paginated paths for collection with pagination enabled" do
    Content::Post.configure do |config|
      config.pagination.per_page = 2
    end

    @paths_builder.get

    assert_includes @paths, "/blog", "First page uses base path"
    assert_includes @paths, "/blog/page/2/", "Second page"

    Content::Post.configure do |config|
      config.pagination.per_page = nil
    end
  end

  test "generates single page when items fit in one page" do
    Content::Post.configure do |config|
      config.pagination.per_page = 10
    end

    @paths_builder.get

    assert_includes @paths, "/blog"
    refute_includes @paths, "/blog/page/2/"

    Content::Post.configure do |config|
      config.pagination.per_page = nil
    end
  end

  test "uses custom path template" do
    Content::Post.configure do |config|
      config.pagination.per_page = 2
      config.pagination.path_template = "/p/:page/"
    end

    @paths_builder.get

    assert_includes @paths, "/blog"
    assert_includes @paths, "/blog/p/2/"

    Content::Post.configure do |config|
      config.pagination.per_page = nil
      config.pagination.path_template = "/page/:page/"
    end
  end
end
