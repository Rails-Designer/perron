require "test_helper"

module TestHelpers
  class PaginateHelperTestController
    include Perron::PaginateHelper

    attr_reader :params

    def initialize(params = {})
      @params = params
    end
  end
end

class Perron::PaginateHelperTest < ActiveSupport::TestCase
  setup do
    @original_per_page = Content::Post.configuration.pagination.per_page
    @controller = TestHelpers::PaginateHelperTestController.new(page: "2")
    @paginated_collection = (1..25).to_a
  end

  teardown do
    Content::Post.configure do |config|
      config.pagination.per_page = @original_per_page
    end
  end

  test "returns paginate object and items tuple" do
    Content::Post.configure do |config|
      config.pagination.per_page = 10
    end

    paginate, items = @controller.paginate(Content::Post, @paginated_collection, page: 2)

    assert_instance_of Perron::Paginate, paginate
    assert_equal [11, 12, 13, 14, 15, 16, 17, 18, 19, 20], items
  end

  test "uses page 1 by default" do
    Content::Post.configure do |config|
      config.pagination.per_page = 10
    end

    controller = TestHelpers::PaginateHelperTestController.new
    _paginate, items = controller.paginate(Content::Post, @paginated_collection)

    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], items
  end

  test "paginate object has correct metadata" do
    Content::Post.configure do |config|
      config.pagination.per_page = 10
    end

    paginate, _items = @controller.paginate(Content::Post, @paginated_collection, page: 2)

    assert_equal 2, paginate.current_page
    assert_equal 3, paginate.total_pages
    assert_equal 25, paginate.total_items
    assert_equal true, paginate.next?
    assert_equal true, paginate.previous?
  end

  test "returns empty items for page beyond total" do
    Content::Post.configure do |config|
      config.pagination.per_page = 10
    end

    _paginate, items = @controller.paginate(Content::Post, @paginated_collection, page: 99)

    assert_equal [21, 22, 23, 24, 25], items
  end

  test "returns empty items when collection is empty" do
    Content::Post.configure do |config|
      config.pagination.per_page = 10
    end

    _paginate, items = @controller.paginate(Content::Post, [], page: 1)

    assert_equal [], items
  end

  test "extracts page from params automatically" do
    Content::Post.configure do |config|
      config.pagination.per_page = 10
    end

    controller = TestHelpers::PaginateHelperTestController.new(page: "3")
    _paginate, items = controller.paginate(Content::Post, @paginated_collection)

    assert_equal [21, 22, 23, 24, 25], items
  end
end
