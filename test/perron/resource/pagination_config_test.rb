require "test_helper"

class Perron::Resource::PaginationConfigTest < ActiveSupport::TestCase
  setup do
    @original_per_page = Content::Post.configuration.pagination.per_page
    @original_path_template = Content::Post.configuration.pagination.path_template
  end

  teardown do
    Content::Post.configure do |config|
      config.pagination.per_page = @original_per_page
      config.pagination.path_template = @original_path_template
    end
  end

  test "pagination defaults to nil per_page (disabled)" do
    Content::Post.instance_variable_set(:@configuration, nil)

    assert_nil Content::Post.configuration.pagination.per_page
  end

  test "can set per_page to enable pagination" do
    Content::Post.configure do |config|
      config.pagination.per_page = 10
    end

    assert_equal 10, Content::Post.configuration.pagination.per_page
  end

  test "can set custom path template" do
    Content::Post.configure do |config|
      config.pagination.path_template = "/p/:page/"
    end

    assert_equal "/p/:page/", Content::Post.configuration.pagination.path_template
  end

  test "path_template defaults to /page/:page/" do
    Content::Post.instance_variable_set(:@configuration, nil)

    assert_equal "/page/:page/", Content::Post.configuration.pagination.path_template
  end

  test "setting per_page enables pagination implicitly" do
    Content::Post.configure do |config|
      config.pagination.per_page = 10
    end

    assert_equal 10, Content::Post.configuration.pagination.per_page
  end

  test "configuration is isolated per resource class" do
    original_posts_per_page = Content::Post.configuration.pagination.per_page

    Content::Post.configure do |config|
      config.pagination.per_page = 10
    end

    posts_config = Content::Post.configuration.pagination.per_page

    Content::Post.configure do |config|
      config.pagination.per_page = original_posts_per_page
    end

    assert_equal 10, posts_config
  end

  test "paginates returns hash with per_page and path_template" do
    Content::Post.configure do |config|
      config.pagination.per_page = 15
      config.pagination.path_template = "/items/:page/"
    end

    pagination = Content::Post.configuration.pagination

    assert_equal 15, pagination.per_page
    assert_equal "/items/:page/", pagination.path_template
  end
end
