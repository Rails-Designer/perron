require "test_helper"

class Perron::Site::Builder::AdditionalRoutesTest < ActiveSupport::TestCase
  setup do
    @paths = Set.new
    @additional_routes = Perron::Site::Builder::AdditionalRoutes.new(@paths)
  end

  test "adds configured additional routes to paths" do
    Perron.configuration.stub :additional_routes, %w[root_path search_path] do
      @additional_routes.get

      assert_includes @paths, "/"
      assert_includes @paths, "/search"
    end
  end

  test "skips routes that don't exist" do
    Perron.configuration.stub :additional_routes, %w[nonexistent_path] do
      @additional_routes.get

      assert_empty @paths
    end
  end

  test "handles empty additional routes" do
    Perron.configuration.stub :additional_routes, [] do
      @additional_routes.get

      assert_empty @paths
    end
  end
end
