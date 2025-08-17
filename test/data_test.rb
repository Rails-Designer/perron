require "test_helper"

class PerronDataTest < ActiveSupport::TestCase
  test "loads yaml file by basename" do
    data = Perron::Data.new("users")

    assert_equal 2, data.count

    first_user = data.first

    assert_equal "Cam", first_user.name
    assert_equal "administrator", first_user[:role]
    assert_equal "<a href=\"https:\/\/example\.com\">Homepage</a>", first_user[:site]
  end

  test "loads json file by basename" do
    data = Perron::Data.new("products")

    assert_equal 2, data.count

    last_product = data.last

    assert_equal "MSE-002", last_product.sku
    assert_equal 25, last_product[:price]
  end

  test "loads csv file by basename" do
    data = Perron::Data.new("orders")

    assert_equal 2, data.count

    first_order = data.first

    assert_equal "101", first_order.order_id
    assert_equal "79", first_order[:amount]
  end

  test "loads file with a full path" do
    full_path = Rails.root.join("app", "content", "data", "users.yml").to_s
    data = Perron::Data.new(full_path)

    assert_equal "Kendall", data.last.name
  end

  test "raises FileNotFoundError for a missing file" do
    assert_raises Perron::Errors::FileNotFoundError do
      Perron::Data.new("non_existent_file")
    end
  end

  test "raises DataParseError for data not structured as an array" do
    assert_raises Perron::Errors::DataParseError do
      Perron::Data.new("not_an_array")
    end
  end
end
