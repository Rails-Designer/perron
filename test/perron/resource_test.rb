require "test_helper"

class Perron::Site::ResourceTest < ActiveSupport::TestCase
  setup do
    @page_path = "test/dummy/app/content/pages/about.md"
    @post_path = "test/dummy/app/content/posts/2023-05-15-sample-post.md"
    @inline_erb_post_path = "test/dummy/app/content/posts/2025-10-01-inline-erb-post.md"
    @page = Content::Page.new(@page_path)
    @post = Content::Post.new(@post_path)
    @inline_erb_post = Content::Post.new(@inline_erb_post_path) # <-- Addition
  end

  test "initialization sets file_path" do
    assert_equal @page_path, @page.file_path
  end

  test "initialization raises error when file doesn't exist" do
    assert_raises Perron::Errors::FileNotFoundError do
      Perron::Resource.new("non_existent_file.md")
    end
  end

  test "#filename returns the basename of the file path" do
    assert_equal "about.md", @page.filename
    assert_equal "2023-05-15-sample-post.md", @post.filename
  end

  test "#slug delegates to Perron::Resource::Slug" do
    assert @page.slug
  end

  test "#path is an alias for slug" do
    assert_equal @post.slug, @post.path
  end

  test "#to_param is an alias for slug" do
    assert_equal @page.slug, @page.to_param
  end

  test "#content returns processed content" do
    assert @post.content
  end

  test "#content renders inline ERB blocks using erbify helper" do
    content = @inline_erb_post.content

    assert_match "The slug for this resource is: inline-erb-post", content
    assert_no_match(/<%= erbify do %>/, content)

    assert_match "This is a regular paragraph", content
    assert_match "And one more paragraph for good measure", content
  end

  test "#metadata returns metadata hash" do
    assert_kind_of Hash, @page.metadata
  end

  test "#raw_content reads the file" do
    assert @post.raw_content
  end

  test "#raw is an alias for raw_content" do
    assert_equal @page.raw_content, @page.raw
  end

  test "#to_partial_path returns the conventional path from a logical name" do
    assert_equal "content/pages/page", @page.to_partial_path
  end

  test "#to_partial_path returns the conventional path from a nested logical name" do
    assert_equal "content/posts/post", @post.to_partial_path
  end
end
