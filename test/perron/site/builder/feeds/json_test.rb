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
      assert_equal 3, json["items"].count, "Should include 3 posts (one is excluded by frontmatter)"

      titles = json["items"].map { it["title"] }
      assert_equal ["Inline ERB post", "Another Sample Post", "Sample Post"], titles, "Posts should be sorted by date descending"
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
      assert_equal "Inline ERB post", json["items"].first["title"]
      assert_equal "http://localhost:3000/blog/inline-erb-post/", json["items"].first["url"]
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

  test "sets a `ref` param to the link" do
    @collection.configuration.feeds.json.stub(:ref, "perron.railsdesigner.com") do
      @collection.configuration.feeds.json.stub(:max_items, 1) do
        json = JSON.parse(@builder.generate)

        assert_equal 1, json["items"].count
        assert_equal "http://localhost:3000/blog/inline-erb-post/?ref=perron.railsdesigner.com", json["items"].first["url"]
      end
    end
  end
end
