require "test_helper"

class Perron::RelationTest < ActiveSupport::TestCase
  setup do
    @posts = Content::Post.all
  end

  test "is an instance of Perron::Relation" do
    assert_instance_of Perron::Relation, @posts
  end

  test "inherits from Array" do
    assert_kind_of Array, @posts
  end

  test "#where filters resources" do
    filtered = @posts.where(slug: "sample-post")

    assert_instance_of Perron::Relation, filtered
    assert_equal 1, filtered.size
  end

  test "#where with array filters with OR logic" do
    filtered = @posts.where(slug: ["sample-post", "another-post"])

    assert_equal 2, filtered.size
  end

  test "#where chains multiple conditions" do
    filtered = @posts.where(slug: "sample-post").where(slug: "sample-post")

    assert_equal 1, filtered.size
  end

  test "#pluck with single attribute returns flat array" do
    slugs = @posts.pluck(:slug)

    assert_instance_of Array, slugs
    assert_equal 4, slugs.size
    assert_includes slugs, "sample-post"
  end

  test "#pluck with multiple attributes returns array of arrays" do
    results = @posts.pluck(:slug, :title)

    assert_equal 4, results.size
    assert_instance_of Array, results.first
    assert_equal 2, results.first.size
  end

  test "#pluck raises ArgumentError when no attributes given" do
    assert_raises ArgumentError do
      @posts.pluck
    end
  end

  test "#order sorts resources ascending" do
    sorted = @posts.order(:slug)

    assert_instance_of Perron::Relation, sorted
    assert_equal "another-post", sorted.first.slug
  end

  test "#order sorts resources descending" do
    sorted = @posts.order(:slug, :desc)

    assert_equal "sample-post", sorted.first.slug
  end

  test "#order sorts resources descending using hash" do
    sorted = @posts.order(slug: :desc)

    assert_equal "sample-post", sorted.first.slug
  end

  test "#limit returns limited relation" do
    limited = @posts.limit(2)

    assert_instance_of Perron::Relation, limited
    assert_equal 2, limited.size
  end

  test "#offset returns offset relation" do
    offset = @posts.offset(2)

    assert_instance_of Perron::Relation, offset
    assert_equal 2, offset.size
  end

  test "chains multiple methods" do
    result = @posts.where(slug: ["sample-post", "another-post"]).order(:slug).limit(1)

    assert_instance_of Perron::Relation, result
    assert_equal 1, result.size
    assert_equal "another-post", result.first.slug
  end

  test "chains with pluck at the end" do
    slugs = @posts.order(:slug).limit(2).pluck(:slug)

    assert_equal 2, slugs.size
    assert_equal "another-post", slugs.first
  end
end
