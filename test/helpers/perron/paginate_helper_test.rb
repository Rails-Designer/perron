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

    controller = TestHelpers::PaginateHelperTestController.new(page: "1")
    paginate, items = controller.paginate(Content::Post.all)

    assert_instance_of Perron::Paginate, paginate
    assert_equal 4, items.size
    assert_equal Content::Post, items.first.class
  end

  test "uses page 1 by default" do
    Content::Post.configure do |config|
      config.pagination.per_page = 10
    end

    controller = TestHelpers::PaginateHelperTestController.new
    paginate, items = controller.paginate(Content::Post.all)

    assert_equal 4, items.size
    assert_equal Content::Post, items.first.class
  end

  test "paginate object has correct metadata" do
    Content::Post.configure do |config|
      config.pagination.per_page = 2
    end

    controller = TestHelpers::PaginateHelperTestController.new(page: "1")
    paginate, items = controller.paginate(Content::Post.all, page: 1)

    assert_equal 1, paginate.current_page
    assert_equal 2, paginate.per_page
    assert_equal 2, items.size
    assert_equal true, paginate.next?
    assert_equal false, paginate.previous?
  end

  test "extracts page from params automatically" do
    Content::Post.configure do |config|
      config.pagination.per_page = 2
    end

    controller = TestHelpers::PaginateHelperTestController.new(page: "2")
    paginate, _items = controller.paginate(Content::Post.all)

    assert_equal 2, paginate.current_page
    assert_equal 2, paginate.per_page
    assert_equal false, paginate.next?
  end

  test "allows per_page override via options" do
    Content::Post.configure do |config|
      config.pagination.per_page = 10
    end

    controller = TestHelpers::PaginateHelperTestController.new(page: "1")
    paginate, items = controller.paginate(Content::Post.all, page: 1, per_page: 2)

    assert_equal 2, paginate.per_page
    assert_equal 2, items.size
    assert_equal Content::Post, items.first.class
  end
end
