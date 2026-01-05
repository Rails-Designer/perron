require "test_helper"

class Perron::Site::DataTest < ActiveSupport::TestCase
  test "loads yaml file by basename" do
    data = Perron::Data.new("users")

    assert_equal 2, data.count

    first_user = data.first

    assert_equal "Cam", first_user.name
    assert_equal "administrator", first_user[:role]
  end

  test "loads nested yaml file by nested basename" do
    data = Perron::Data.new("users/admins")

    assert_equal 1, data.count

    first_user = data.first

    assert_equal "Cam", first_user.name
    assert_equal "all", first_user[:access]
  end


  test "loads json file by basename" do
    data = Perron::Data.new("skus")

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

  test ".all returns dataset for the class" do
    data = Content::Data::Users.all

    assert_equal 2, data.count
    assert_equal "Cam", data.first.name
  end

  test ".find returns item by id" do
    user = Content::Data::Users.find("cam")

    assert_equal "Cam", user.name
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

  test "#to_partial_path returns the conventional path from a logical name" do
    data = Perron::Data.new("users")

    assert_equal "content/users/user", data.first.to_partial_path
  end

  test "#to_partial_path returns the conventional path from a nested logical name" do
    data = Perron::Data.new("users/admins")

    assert_equal "content/users/admins/admin", data.first.to_partial_path
  end

  test "#to_partial_path returns the conventional path from a full file path" do
    full_path = Rails.root.join("app", "content", "data", "skus.json").to_s
    data = Perron::Data.new(full_path)

    assert_equal "content/skus/sku", data.first.to_partial_path
  end

  test "parses YAML literal block scalar" do
    data = Perron::Data.new("users")

    assert_includes data.first.bio, "\n"
  end

  test "parses YAML folded block scalar" do
    data = Perron::Data.new("users")

    refute_includes data.last.bio.strip, "\n"
  end

  test "parses YAML literal keep block scalar" do
    data = Perron::Data.new("users")

    assert_match (/\n\n\z/), data.first.notes
  end

  test "parses YAML folded strip block scalar" do
    data = Perron::Data.new("users")

    refute_match (/\n\z/), data.last.notes
  end
end
