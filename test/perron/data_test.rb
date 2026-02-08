require "test_helper"

class Perron::Site::DataTest < ActiveSupport::TestCase
  test "loads yaml file by basename" do
    data = Content::Data.new("users")

    assert_equal 2, data.count

    first_user = data.first

    assert_equal "Cam", first_user.name
    assert_equal "administrator", first_user[:role]
  end

  test "loads nested yaml file by nested basename" do
    data = Content::Data.new("users/admins")

    assert_equal 1, data.count

    first_user = data.first

    assert_equal "Cam", first_user.name
    assert_equal "all", first_user[:access]
  end


  test "loads json file by basename" do
    data = Content::Data.new("skus")

    assert_equal 2, data.count

    last_product = data.last

    assert_equal "MSE-002", last_product.sku
    assert_equal 25, last_product[:price]
  end

  test "loads csv file by basename" do
    data = Content::Data.new("orders")

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
    data = Content::Data.new(full_path)

    assert_equal "Kendall", data.last.name
  end

  test "raises FileNotFoundError for a missing file" do
    assert_raises Perron::Errors::FileNotFoundError do
      Content::Data.new("non_existent_file")
    end
  end

  test "raises DataParseError for data not structured as an array" do
    assert_raises Perron::Errors::DataParseError do
      Content::Data.new("not_an_array")
    end
  end

  test "#to_partial_path returns the conventional path from a logical name" do
    data = Content::Data.new("users")

    assert_equal "content/users/user", data.first.to_partial_path
  end

  test "#to_partial_path returns the conventional path from a nested logical name" do
    data = Content::Data.new("users/admins")

    assert_equal "content/users/admins/admin", data.first.to_partial_path
  end

  test "#to_partial_path returns the conventional path from a full file path" do
    full_path = Rails.root.join("app", "content", "data", "skus.json").to_s
    data = Content::Data.new(full_path)

    assert_equal "content/skus/sku", data.first.to_partial_path
  end

  test "parses YAML literal block scalar" do
    data = Content::Data.new("users")

    assert_includes data.first.bio, "\n"
  end

  test "parses YAML folded block scalar" do
    data = Content::Data.new("users")

    refute_includes data.last.bio.strip, "\n"
  end

  test "parses YAML literal keep block scalar" do
    data = Content::Data.new("users")

    assert_match (/\n\n\z/), data.first.notes
  end

  test "parses YAML folded strip block scalar" do
    data = Content::Data.new("users")

    refute_match (/\n\z/), data.last.notes
  end

  test ".count returns the number of items" do
    assert_equal 2, Content::Data::Users.count
  end

  test ".first returns the first item" do
    user = Content::Data::Users.first

    assert_equal "Cam", user.name
  end

  test ".second returns the second item" do
    user = Content::Data::Users.second

    assert_equal "Kendall", user.name
  end

  test ".third returns the third item" do
    assert_nil Content::Data::Users.third
  end

  test ".last returns the last item" do
    user = Content::Data::Users.last

    assert_equal "Kendall", user.name
  end

  test ".take returns the first n items" do
    users = Content::Data::Users.take(1)

    assert_equal 1, users.size
    assert_equal "Cam", users.first.name
  end

  test "#select filters items" do
    admins = Content::Data.new("users").select { it[:role] == "administrator" }

    assert_equal 1, admins.count
    assert_equal "Cam", admins.first.name
  end

  test "#map transforms items" do
    names = Content::Data.new("users").map(&:name)

    assert_equal ["Cam", "Kendall"], names
  end

  test "#sort_by orders items" do
    sorted = Content::Data.new("users").sort_by(&:name)

    assert_equal "Cam", sorted.first.name
    assert_equal "Kendall", sorted.last.name
  end

  test "#group_by groups items" do
    grouped = Content::Data.new("users").group_by { it[:role] }

    assert_equal 1, grouped["administrator"].size
    assert_equal 1, grouped["moderator"].size
  end

  test "#any? returns true when condition matches" do
    data = Content::Data.new("users")

    assert data.any? { it.name == "Cam" }
    refute data.any? { it.name == "NonExistent" }
  end

  test "#all? returns true when all match condition" do
    data = Content::Data.new("users")

    assert data.all? { it.name.is_a?(String) }
    refute data.all? { it[:role] == "administrator" }
  end

  test "#find_all returns matching items" do
    cheap_items = Content::Data.new("skus").find_all { it[:price] < 30 }

    assert_equal 1, cheap_items.count
  end

  test "#reject filters out items" do
    non_admins = Content::Data.new("users").reject { it[:role] == "administrator" }

    assert_equal 1, non_admins.count
    assert_equal "Kendall", non_admins.first.name
  end

  test "#each_with_index provides index" do
    result = []

    Content::Data.new("users").each_with_index { |user, index| result << [user.name, index] }

    assert_equal [["Cam", 0], ["Kendall", 1]], result
  end

  test "#partition splits into two arrays" do
    data = Content::Data.new("users")
    admins, others = data.partition { it[:role] == "administrator" }

    assert_equal 1, admins.size
    assert_equal 1, others.size
  end

  test "#[] accesses items by index" do
    data = Content::Data.new("users")

    assert_equal "Cam", data[0].name
    assert_equal "Kendall", data[1].name
    assert_nil data[2]
  end

  test "raises DataParseError for malformed CSV with column mismatch" do
    error = assert_raises Perron::Errors::DataParseError do
      Content::Data.new("malformed_csv")
    end

    assert_includes error.message, "Column mismatch"
    assert_includes error.message, "Expected: name, email, role"
  end

  test "raises DataParseError for malformed JSON" do
    error = assert_raises Perron::Errors::DataParseError do
      Content::Data.new("malformed_json")
    end

    assert_includes error.message, "Invalid JSON syntax"
  end

  test "raises DataParseError for malformed YAML" do
    error = assert_raises Perron::Errors::DataParseError do
      Content::Data.new("malformed_yml")
    end

    assert_includes error.message, "Invalid YAML syntax"
  end
end
