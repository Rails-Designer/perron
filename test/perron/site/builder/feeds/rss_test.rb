require "test_helper"

class Perron::Site::Builder::Feeds::RssTest < ActiveSupport::TestCase
  include ConfigurationHelper
  include FeedConfigurationHelper

  setup do
    @collection = Perron::Site.collection("posts")
    @builder = Perron::Site::Builder::Feeds::Rss.new(collection: @collection)
  end

  test "generates correct RSS string with items sorted by date" do
    @collection.configuration.feeds.rss.max_items = 10

    rss = Nokogiri::XML(@builder.generate).remove_namespaces!

    assert_equal "Dummy App", rss.at_xpath("//channel/title").text
    assert_equal "", rss.at_xpath("//channel/description").text
    assert_equal "http://localhost:3000/", rss.at_xpath("//channel/link").text
    assert_equal 2, rss.xpath("//item").count, "Should include 2 posts (one is excluded by frontmatter)"

    titles = rss.xpath("//item/title").map(&:text)
    assert_equal ["Another Sample Post", "Sample Post"], titles, "Posts should be sorted by date descending"
  end

  test "respects max_items configuration" do
    @collection.configuration.feeds.rss.max_items = 1

    rss = Nokogiri::XML(@builder.generate).remove_namespaces!

    assert_equal 1, rss.xpath("//item").count
    assert_equal "Another Sample Post", rss.at_xpath("//item/title").text
  end

  test "configured feed name and description" do
    @collection.configuration.feeds.rss.title = "Custom RSS title"
    @collection.configuration.feeds.rss.description = "Custom RSS description"

    rss = Nokogiri::XML(@builder.generate).remove_namespaces!

    assert_equal "Custom RSS title", rss.at_xpath("//channel/title").text
    assert_equal "Custom RSS description", rss.at_xpath("//channel/description").text
  end
end
