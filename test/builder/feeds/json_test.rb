require "test_helper"

module Perron
  module Site
    class Builder
      class Feeds
        class JsonTest < ActiveSupport::TestCase
          include ConfigurationHelper

          setup do
            @collection = Perron::Site.collection("posts")
            @builder = Json.new(collection: @collection)
          end

          test "generates correct JSON Feed string with items sorted by date" do
            @collection.configuration.feeds.json.max_items = 10

            json = JSON.parse(@builder.generate)

            assert_equal "https://jsonfeed.org/version/1.1", json["version"]
            assert_equal "Dummy App", json["title"]
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
        end
      end
    end
  end
end
