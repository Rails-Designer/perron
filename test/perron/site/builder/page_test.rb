require "test_helper"

class Perron::Site::Builder::PageTest < ActiveSupport::TestCase
  test "recognize_path_with_pagination_fallback extracts page number from paginated path" do
    page = Perron::Site::Builder::Page.new("/anything/page/2/")

    route_info = page.send(:recognize_path_with_pagination_fallback, "/anything/page/2/")

    assert_equal 2, route_info[:page]
  end

  test "recognize_path_with_pagination_fallback handles high page numbers" do
    page = Perron::Site::Builder::Page.new("/anything/page/15/")

    route_info = page.send(:recognize_path_with_pagination_fallback, "/anything/page/15/")

    assert_equal 15, route_info[:page]
  end

  test "recognize_path_with_pagination_fallback adds page to route params" do
    page = Perron::Site::Builder::Page.new("/articles/page/99/")

    route_info = page.send(:recognize_path_with_pagination_fallback, "/articles/page/99/")

    assert_equal 99, route_info[:page]
  end
end
