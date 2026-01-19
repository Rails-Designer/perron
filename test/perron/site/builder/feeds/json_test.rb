require "test_helper"

class Perron::Site::Builder::Feeds::JsonTest < ActiveSupport::TestCase
  include ConfigurationHelper

  setup do
    @collection = Perron::Site.collection("posts")
    @builder = Perron::Site::Builder::Feeds::Json.new(collection: @collection)
  end

  test "generates correct JSON Feed string with items sorted by date" do
    @collection.configuration.feeds.json.stub(:max_items, 10) do
      json = JSON.parse(@builder.generate)

      assert_equal "Perron (#{Perron::VERSION})", json["generator"]
      assert_equal "https://jsonfeed.org/version/1.1", json["version"]
      assert_equal "Dummy App", json["title"]
      assert_nil json["description"]
      assert_equal "http://localhost:3000/", json["home_page_url"]
      assert_operator json["items"].count, :>, 0, "Should include at least one post"

      pub_dates = json["items"].map { it["date_published"] }
      assert_equal pub_dates.sort.reverse, pub_dates, "Posts should be sorted by date descending"
    end
  end

  test "configured feed name and description" do
    @collection.configuration.feeds.json.stub(:title, "Custom JSON title") do
      json = JSON.parse(@builder.generate)

      assert_equal "Custom JSON title", json["title"]
    end

    @collection.configuration.feeds.json.stub(:description, "Custom JSON description") do
      json = JSON.parse(@builder.generate)

      assert_equal "Custom JSON description", json["description"]
    end
  end

  test "respects max_items configuration" do
    @collection.configuration.feeds.json.stub(:max_items, 1) do
      json = JSON.parse(@builder.generate)

      assert_equal 1, json["items"].count
    end
  end

  test "includes authors when present" do
    @collection.configuration.feeds.json.stub(:max_items, 10) do
      json = JSON.parse(@builder.generate)

      item_with_author = json["items"].find { it["title"] == "Sample Post" }

      assert_not_nil item_with_author["authors"]
      assert_equal 1, item_with_author["authors"].count
      assert_equal "Rails Designer", item_with_author["authors"].first["name"]
      assert_equal "support@railsdesigner.com", item_with_author["authors"].first["email"]
    end
  end

  test "includes authors from config when belongs_to author not defined" do
    @collection.configuration.feeds.json.stub(:max_items, 10) do
      json = JSON.parse(@builder.generate)

      item_with_author = json["items"].find { it["title"] == "No author" }

      assert_not_nil item_with_author["authors"]
      assert_equal 1, item_with_author["authors"].count
      assert_equal "JSON Config Author", item_with_author["authors"].first["name"]
      assert_equal "support@railsdesigner.com", item_with_author["authors"].first["email"]
    end
  end

  test "sets a `ref` param to the link" do
    @collection.configuration.feeds.json.stub(:ref, "perron.railsdesigner.com") do
      @collection.configuration.feeds.json.stub(:max_items, 1) do
        json = JSON.parse(@builder.generate)

        assert_equal 1, json["items"].count
        assert_match %r{\?ref=perron\.railsdesigner\.com$}, json["items"].first["url"], "Should include ref parameter"
      end
    end
  end
end
