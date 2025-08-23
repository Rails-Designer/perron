require "test_helper"

class Perron::Site::Builder::Feeds::RssTest < ActiveSupport::TestCase
  include ConfigurationHelper

  setup do
    @collection = Perron::Site.collection("posts")
    @builder = Perron::Site::Builder::Feeds::Rss.new(collection: @collection)
  end

  test "generates correct RSS string with items sorted by date" do
    @collection.configuration.feeds.rss.max_items = 10

    document = Nokogiri::XML(@builder.generate).remove_namespaces!

    assert_equal "Dummy App", document.at_xpath("//channel/title").text
    assert_equal 2, document.xpath("//item").count, "Should include 2 posts (one is excluded by frontmatter)"

    titles = document.xpath("//item/title").map(&:text)
    assert_equal ["Another Sample Post", "Sample Post"], titles, "Posts should be sorted by date descending"
  end

  test "respects max_items configuration" do
    @collection.configuration.feeds.rss.max_items = 1

    document = Nokogiri::XML(@builder.generate).remove_namespaces!

    assert_equal 1, document.xpath("//item").count
    assert_equal "Another Sample Post", document.at_xpath("//item/title").text
  end
end
