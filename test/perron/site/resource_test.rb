require "test_helper"

class Perron::Site::ResourceTest < ActiveSupport::TestCase
  setup do
    @page_path = "test/dummy/app/content/pages/about.md"
    @post_path = "test/dummy/app/content/posts/2023-05-15-sample-post.md"
    @resource = Perron::Resource.new(@page_path)
  end

  test "initialization sets file_path" do
    assert_equal @page_path, @resource.file_path
  end

  test "initialization raises error when file doesn't exist" do
    assert_raises Perron::Errors::FileNotFoundError do
      Perron::Resource.new("non_existent_file.md")
    end
  end

  test "#filename returns the basename of the file path" do
    assert_equal "about.md", @resource.filename
    assert_equal "2023-05-15-sample-post.md", Perron::Resource.new(@post_path).filename
  end

  test "#slug delegates to Perron::Resource::Slug" do
    assert @resource.slug
  end

  test "#path is an alias for slug" do
    assert_equal @resource.slug, @resource.path
  end

  test "#to_param is an alias for slug" do
    assert_equal @resource.slug, @resource.to_param
  end

  test "#content returns processed content" do
    assert @resource.content
  end

  test "#metadata returns metadata hash" do
    assert_kind_of Hash, @resource.metadata
  end

  test "#raw_content reads the file" do
    assert_equal File.read(@page_path), @resource.raw_content
  end

  test "#raw is an alias for raw_content" do
    assert_equal @resource.raw_content, @resource.raw
  end
end
