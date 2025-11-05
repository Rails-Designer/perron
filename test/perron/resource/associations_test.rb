require "test_helper"

class Perron::Resource::AssociationsTest < ActiveSupport::TestCase
  setup do
    @post_path = "test/dummy/app/content/posts/2023-05-15-sample-post.md"
    @author_path = "test/dummy/app/content/authors/rails-designer.md"

    @post = Content::Post.new(@post_path)
    @author = Content::Author.new(@author_path)
  end

  test "belongs_to returns associated resource" do
    assert_kind_of Content::Author, @post.author
    assert_equal "rails-designer", @post.author.slug
  end

  test "belongs_to returns nil when foreign key is missing" do
    post_without_author_path = "test/dummy/app/content/posts/2025-10-01-inline-erb-post.md"
    post_without_author = Content::Post.new(post_without_author_path)

    assert_nil post_without_author.author
  end

  test "belongs_to caches the association" do
    first_call = @post.author
    second_call = @post.author

    assert_same first_call, second_call
  end

  test "has_many returns collection of associated resources" do
    posts = @author.posts

    assert_kind_of Array, posts
    assert posts.all? { it.is_a?(Content::Post) }
    assert posts.any? { it.metadata["author_id"] == @author.slug }
  end

  test "has_many returns empty array when no associations exist" do
    author_without_posts_path = "test/dummy/app/content/authors/not-rails-designer.md"
    author_without_posts = Content::Author.new(author_without_posts_path)

    assert_equal [], author_without_posts.posts
  end

  test "has_many caches the association" do
    first_call = @author.posts
    second_call = @author.posts

    assert_same first_call, second_call
  end

  test "associations work bidirectionally" do
    author = @post.author
    author_post_ids = author.posts.map { it.metadata["author_id"] }

    assert author_post_ids.all? { it == author.slug }
  end
end
