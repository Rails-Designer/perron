require "test_helper"

class Perron::PaginateTest < ActiveSupport::TestCase
  setup do
    @paginated_collection = (1..25).to_a
  end

  test "returns current page number" do
    paginate = Perron::Paginate.new(@paginated_collection, page: 2, per_page: 10)

    assert_equal 2, paginate.current_page
  end

  test "returns total pages" do
    paginate = Perron::Paginate.new(@paginated_collection, page: 1, per_page: 10)

    assert_equal 3, paginate.total_pages
  end

  test "returns per_page setting" do
    paginate = Perron::Paginate.new(@paginated_collection, page: 1, per_page: 10)

    assert_equal 10, paginate.per_page
  end

  test "returns total items count" do
    paginate = Perron::Paginate.new(@paginated_collection, page: 1, per_page: 10)

    assert_equal 25, paginate.total_items
  end

  test "returns items for current page" do
    paginate = Perron::Paginate.new(@paginated_collection, page: 1, per_page: 10)

    items = paginate.items

    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], items
  end

  test "returns second page items" do
    paginate = Perron::Paginate.new(@paginated_collection, page: 2, per_page: 10)

    items = paginate.items

    assert_equal [11, 12, 13, 14, 15, 16, 17, 18, 19, 20], items
  end

  test "returns last page items" do
    paginate = Perron::Paginate.new(@paginated_collection, page: 3, per_page: 10)

    items = paginate.items

    assert_equal [21, 22, 23, 24, 25], items
  end

  test "has next page when not on last" do
    paginate = Perron::Paginate.new(@paginated_collection, page: 1, per_page: 10)

    assert_equal true, paginate.next?
  end

  test "no next page on last page" do
    paginate = Perron::Paginate.new(@paginated_collection, page: 3, per_page: 10)

    assert_equal false, paginate.next?
  end

  test "has previous page when not on first" do
    paginate = Perron::Paginate.new(@paginated_collection, page: 2, per_page: 10)

    assert_equal true, paginate.previous?
  end

  test "no previous page on first page" do
    paginate = Perron::Paginate.new(@paginated_collection, page: 1, per_page: 10)

    assert_equal false, paginate.previous?
  end

  test "clamps page to valid range" do
    paginate = Perron::Paginate.new(@paginated_collection, page: 99, per_page: 10)

    assert_equal 3, paginate.current_page
  end

  test "clamps page below 1 to 1" do
    paginate = Perron::Paginate.new(@paginated_collection, page: 0, per_page: 10)

    assert_equal 1, paginate.current_page
  end

  test "handles negative page" do
    paginate = Perron::Paginate.new(@paginated_collection, page: -1, per_page: 10)

    assert_equal 1, paginate.current_page
  end

  test "handles single page" do
    paginate = Perron::Paginate.new((1..5).to_a, page: 1, per_page: 10)

    assert_equal 1, paginate.total_pages
    assert_equal false, paginate.next?
    assert_equal false, paginate.previous?
  end

  test "handles exact page division" do
    paginate = Perron::Paginate.new((1..20).to_a, page: 1, per_page: 10)

    assert_equal 2, paginate.total_pages
  end

  test "returns zero total pages for empty collection" do
    paginate = Perron::Paginate.new([], page: 1, per_page: 10)

    assert_equal 0, paginate.total_pages
    assert_equal [], paginate.items
  end

  test "first page with empty collection has no next" do
    paginate = Perron::Paginate.new([], page: 1, per_page: 10)

    assert_equal false, paginate.next?
  end

  test "empty collection has page 1 for consistency" do
    paginate = Perron::Paginate.new([], page: 1, per_page: 10)

    assert_equal 1, paginate.current_page
  end

  test "previous returns base path on page 2" do
    paginate = Perron::Paginate.new((1..10).to_a, page: 2, per_page: 5, base_path: "/posts/")

    assert_equal "/posts/", paginate.previous
  end

  test "previous returns paginated path on page 3" do
    paginate = Perron::Paginate.new((1..15).to_a, page: 3, per_page: 5, base_path: "/posts/")

    assert_equal "/posts/page/2/", paginate.previous
  end

  test "previous returns nil on page 1" do
    paginate = Perron::Paginate.new((1..10).to_a, page: 1, per_page: 5, base_path: "/posts/")

    assert_nil paginate.previous
  end

  test "next returns paginated path on first page" do
    paginate = Perron::Paginate.new((1..10).to_a, page: 1, per_page: 5, base_path: "/posts/")

    assert_equal "/posts/page/2/", paginate.next
  end

  test "next returns paginated path on middle page" do
    paginate = Perron::Paginate.new((1..15).to_a, page: 2, per_page: 5, base_path: "/posts/")

    assert_equal "/posts/page/3/", paginate.next
  end

  test "next returns nil on last page" do
    paginate = Perron::Paginate.new((1..10).to_a, page: 2, per_page: 5, base_path: "/posts/")

    assert_nil paginate.next
  end

  test "previous uses base_path with trailing slash" do
    paginate = Perron::Paginate.new((1..10).to_a, page: 2, per_page: 5, base_path: "/articles/")

    assert_equal "/articles/", paginate.previous
  end

  test "next uses base_path with trailing slash" do
    paginate = Perron::Paginate.new((1..10).to_a, page: 1, per_page: 5, base_path: "/articles/")

    assert_equal "/articles/page/2/", paginate.next
  end

  test "uses query params when use_query_params is true" do
    paginate = Perron::Paginate.new((1..10).to_a, page: 1, per_page: 5, base_path: "/articles/", use_query_params: true)

    assert_equal "/articles/?page=2", paginate.next
  end

  test "uses path-based URLs when use_query_params is false" do
    paginate = Perron::Paginate.new((1..10).to_a, page: 1, per_page: 5, base_path: "/articles/", use_query_params: false)

    assert_equal "/articles/page/2/", paginate.next
  end

  test "previous uses query params when use_query_params is true" do
    paginate = Perron::Paginate.new((1..15).to_a, page: 4, per_page: 5, base_path: "/articles/", use_query_params: true)

    assert_equal "/articles/?page=2", paginate.previous
  end
end
