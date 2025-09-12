require "test_helper"

class Perron::Site::Builder::Feeds::JsonTest < ActiveSupport::TestCase
  include ConfigurationHelper
  include FeedConfigurationHelper

  setup do
    @collection = Perron::Site.collection("posts")
    @builder = Perron::Site::Builder::Feeds::Json.new(collection: @collection)
  end

  test "generates correct JSON Feed string with items sorted by date" do
    @collection.configuration.feeds.json.max_items = 10

    json = JSON.parse(@builder.generate)

    assert_equal "https://jsonfeed.org/version/1.1", json["version"]
    assert_equal "Dummy App", json["title"]
    assert_nil json["description"]
    assert_equal "http://localhost:3000/", json["home_page_url"]
    assert_equal 2, json["items"].count, "Should include 2 posts (one is excluded by frontmatter)"

    titles = json["items"].map { it["title"] }
    assert_equal ["Another Sample Post", "Sample Post"], titles, "Posts should be sorted by date descending"
  end

  test "respects max_items configuration" do
    @collection.configuration.feeds.json.max_items = 1

    json = JSON.parse(@builder.generate)

    assert_equal 1, json["items"].count
    assert_equal "Another Sample Post", json["items"].first["title"]
  end

  test "configured feed name and description" do
    @collection.configuration.feeds.json.title = "Custom JSON title"
    @collection.configuration.feeds.json.description = "Custom JSON description"

    json = JSON.parse(@builder.generate)

    assert_equal "Custom JSON title", json["title"]
    assert_equal "Custom JSON description", json["description"]
  end
end
