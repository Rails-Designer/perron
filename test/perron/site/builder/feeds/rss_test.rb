require "test_helper"

class Perron::Site::Builder::Feeds::RssTest < ActiveSupport::TestCase
  include ConfigurationHelper

  setup do
    @collection = Perron::Site.collection("posts")
    @builder = Perron::Site::Builder::Feeds::Rss.new(collection: @collection)
  end

  test "generates correct RSS string with items sorted by date" do
    @collection.configuration.feeds.rss.stub(:max_items, 10) do
      rss = Nokogiri::XML(@builder.generate).remove_namespaces!

      assert_equal "Perron (#{Perron::VERSION})", rss.at_xpath("//channel/generator").text
      assert_equal "Dummy App", rss.at_xpath("//channel/title").text
      assert_equal "", rss.at_xpath("//channel/description").text
      assert_equal "http://localhost:3000/", rss.at_xpath("//channel/link").text
      assert_equal 3, rss.xpath("//item").count, "Should include 2 posts (one is excluded by frontmatter)"

      titles = rss.xpath("//item/title").map(&:text)
      assert_equal ["Inline ERB post", "Another Sample Post", "Sample Post"], titles, "Posts should be sorted by date descending"
    end
  end

  test "respects max_items configuration" do
    @collection.configuration.feeds.rss.stub(:max_items, 1) do
      rss = Nokogiri::XML(@builder.generate).remove_namespaces!

      assert_equal 1, rss.xpath("//item").count
      assert_equal "Inline ERB post", rss.at_xpath("//item/title").text
    end
  end

  test "configured feed name and description" do
    @collection.configuration.feeds.rss.stub(:title, "Custom RSS title") do
      rss = Nokogiri::XML(@builder.generate).remove_namespaces!

      assert_equal "Custom RSS title", rss.at_xpath("//channel/title").text
    end

    @collection.configuration.feeds.rss.stub(:description, "Custom RSS description") do
      rss = Nokogiri::XML(@builder.generate).remove_namespaces!

      assert_equal "Custom RSS description", rss.at_xpath("//channel/description").text
    end
  end

  test "uses polymorphic links for items" do
    @collection.configuration.feeds.rss.stub(:max_items, 1) do
      rss = Nokogiri::XML(@builder.generate).remove_namespaces!

      assert_equal 1, rss.xpath("//item").count
      assert_equal "http://localhost:3000/blog/inline-erb-post/", rss.at_xpath("//item/link").text
    end
  end

  test "sets a `ref` param to the link" do
    @collection.configuration.feeds.rss.stub(:ref, "perron.railsdesigner.com") do
      @collection.configuration.feeds.rss.stub(:max_items, 1) do
        rss = Nokogiri::XML(@builder.generate).remove_namespaces!

        assert_equal 1, rss.xpath("//item").count
        assert_equal "http://localhost:3000/blog/inline-erb-post/?ref=perron.railsdesigner.com", rss.at_xpath("//item/link").text
      end
    end
  end
end
