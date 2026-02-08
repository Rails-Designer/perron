require "test_helper"

class Perron::Resource::ScopesTest < ActiveSupport::TestCase
  test "defines a scope" do
    Content::Post.scope :recent, -> { limit(2) }

    assert_respond_to Content::Post, :recent
  end

  test "scope returns filtered relation" do
    Content::Post.scope :by_slug, ->(slug) { where(slug: slug) }

    posts = Content::Post.by_slug("sample-post")

    assert_instance_of Perron::Relation, posts
    assert_equal 1, posts.size
    assert_equal "sample-post", posts.first.slug
  end

  test "scope can be chained" do
    posts = Content::Post.ordered.limited

    assert_equal 2, posts.size
    assert_equal "another-post", posts.first.slug
  end

  test "scope raises error if body is not callable" do
    assert_raises ArgumentError do
      Content::Post.scope :invalid, "not callable"
    end
  end

  test "scope raises error if name already exists" do
    assert_raises ArgumentError do
      Content::Post.scope :all, -> { limit(1) }
    end
  end
end
